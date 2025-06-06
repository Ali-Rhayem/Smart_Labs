using backend.helpers;
using backend.Models;
using MongoDB.Driver;
using backend.Services;
using OneOf;
using System.Globalization;
using MongoDB.Bson;
using System.Text.Json;

public class LabService : ILabService
{
    private readonly IMongoCollection<Lab> _labs;
    private readonly ILabHelper _labHelper;
    private readonly IUserService _userService;
    private readonly ISemesterService _semesterService;
    private readonly IPPEService _ppeService;
    private readonly IRoomService _roomService;
    private readonly ISessionService _sessionService;
    private readonly IKafkaProducer _kafkaProducer;
    private readonly INotificationService _notificationService;

    public LabService(IMongoDatabase database, ILabHelper labHelper, IUserService userService, ISemesterService semesterService, IPPEService ppeService, ISessionService sessionService, IKafkaProducer kafkaProducer, IRoomService roomService, INotificationService notificationService)
    {
        _labs = database.GetCollection<Lab>("Labs");
        _labHelper = labHelper;
        _userService = userService;
        _semesterService = semesterService;
        _ppeService = ppeService;
        _sessionService = sessionService;
        _kafkaProducer = kafkaProducer;
        _roomService = roomService;
        _notificationService = notificationService;
    }

    public async Task<List<Lab>> GetAllLabsAsync()
    {
        return await _labs.Find(_ => true).ToListAsync();
    }

    public async Task<List<Lab>> GetInstructorLabsAsync(int instructorId, bool active = false)
    {
        var instructorFilter = Builders<Lab>.Filter.AnyEq(l => l.Instructors, instructorId);
        var filter = instructorFilter;

        if (active)
        {
            var endLabFilter = Builders<Lab>.Filter.Eq(l => l.EndLab, false);
            filter = Builders<Lab>.Filter.And(instructorFilter, endLabFilter);
        }

        return await _labs.Find(filter).ToListAsync();
    }

    public async Task<List<User>?> GetStudentsInLabAsync(int labId)
    {
        var lab = await _labs.Find(lab => lab.Id == labId).FirstOrDefaultAsync();
        var students = new List<User>();
        if (lab == null)
        {
            return null;
        }
        foreach (var studentId in lab.Students)
        {
            var student = await _userService.GetUserById(studentId);
            if (student != null)
            {
                students.Add(student);
            }
        }
        return students;
    }

    public async Task<List<User>?> GetInstructorsInLabAsync(int labId)
    {
        var lab = await _labs.Find(lab => lab.Id == labId).FirstOrDefaultAsync();
        var instructors = new List<User>();
        if (lab == null)
        {
            return null;
        }
        foreach (var instructorId in lab.Instructors)
        {
            var instructor = await _userService.GetUserById(instructorId);
            if (instructor != null)
            {
                instructors.Add(instructor);
            }
        }
        return instructors;
    }

    public async Task<List<Lab>> GetStudentLabsAsync(int studentId)
    {
        // skip the report
        var projection = Builders<Lab>.Projection
            .Exclude(l => l.Report);

        return await _labs.Find(lab => lab.Students.Contains(studentId)).Project<Lab>(projection).ToListAsync();
    }

    public async Task<Lab> GetLabByIdAsync(int id)
    {
        return await _labs.Find(lab => lab.Id == id).FirstOrDefaultAsync();
    }

    public async Task<OneOf<Lab, ErrorMessage>> CreateLabAsync(Lab lab, List<string> student_emails, List<string> instructors_emails)
    {
        // check if instructors exist in the database
        foreach (var instructor_email in instructors_emails)
        {
            var instructor = await _userService.GetUserByEmailAsync(instructor_email);
            if (instructor != null && instructor.Role == "instructor" && !lab.Instructors.Contains(instructor.Id))
                lab.Instructors.Add(instructor.Id);
        }
        if (lab.Instructors.Count == 0)
        {
            return new ErrorMessage { StatusCode = 400, Message = "can't create lab without instructor" };
        }

        // check if semester exists in the database
        if (await _semesterService.GetSemesterByIdAsync(lab.SemesterID) == null && lab.SemesterID != 0)
        {
            return new ErrorMessage { StatusCode = 404, Message = "semester not found" };
        }

        // check if PPE exists in the database
        foreach (var ppeId in lab.PPE)
        {
            var ppe = await _ppeService.GetListOfPPEsAsync([ppeId]);
            if (ppe.Count == 0)
                lab.PPE.Remove(ppeId);
        }

        // check if room exists in the database
        var rooms = await _roomService.GetAllRoomsAsync();
        if (!rooms.Any(room => room.Name == lab.Room))
        {
            return new ErrorMessage { StatusCode = 404, Message = "room not found" };
        }

        // check if time is valid and thier is no conflict in room or with instructor
        foreach (var labTime in lab.Schedule)
        {
            var validDays = new HashSet<string> { "Monday", "Tuesday", "Wednesday", "Thursday", "Friday", "Saturday", "Sunday" };

            if (!validDays.Contains(labTime.DayOfWeek))
            {
                return new ErrorMessage { StatusCode = 400, Message = "invalid day" };
            }

            if (labTime.StartTime >= labTime.EndTime)
                return new ErrorMessage { StatusCode = 400, Message = "Start time must be before end time" };

            // check if conflict with room
            foreach (var roomLab in await _labs.Find(l => l.Room.ToLower() == lab.Room.ToLower() && l.EndLab == false).ToListAsync())
            {
                foreach (var roomLabTime in roomLab.Schedule)
                {
                    if (labTime.DayOfWeek == roomLabTime.DayOfWeek)
                    {
                        if ((labTime.StartTime < roomLabTime.EndTime && labTime.StartTime >= roomLabTime.StartTime) ||
                            (labTime.EndTime <= roomLabTime.EndTime && labTime.EndTime > roomLabTime.StartTime))
                        {
                            return new ErrorMessage { StatusCode = 409, Message = "room time conflict" };
                        }
                    }
                }
            }

            // check if conflict with instructor
            foreach (var instructorId in lab.Instructors)
            {
                var instructor_labs = await GetInstructorLabsAsync(instructorId, true);
                foreach (var instructorLab in instructor_labs)
                {
                    foreach (var instructorLabTime in instructorLab.Schedule)
                    {
                        if (labTime.DayOfWeek == instructorLabTime.DayOfWeek)
                        {
                            if ((labTime.StartTime < instructorLabTime.EndTime && labTime.StartTime >= instructorLabTime.StartTime) ||
                                (labTime.EndTime <= instructorLabTime.EndTime && labTime.EndTime > instructorLabTime.StartTime))
                            {
                                return new ErrorMessage { StatusCode = 409, Message = "instructor time conflict" };
                            }
                        }
                    }
                }
            }
        }

        // check if students exist in the database
        foreach (var studentEmail in student_emails)
        {
            var student = await _userService.GetUserByEmailAsync(studentEmail);
            if (student == null)
            {
                bool create_student = _labHelper.CreateStudentIfNotExists(studentEmail);
                if (!create_student)
                    return new ErrorMessage { StatusCode = 400, Message = "can't create student" };
            }
        }
        List<int> student_ids = [];
        foreach (var studentEmail in student_emails)
        {
            var student = await _userService.GetUserByEmailAsync(studentEmail);
            if (student.Role == "student")
                student_ids.Add(student.Id);
        }
        lab.Students = student_ids;

        var lastLab = _labs.Find(_ => true).SortByDescending(lab => lab.Id).FirstOrDefault();
        var labId = lastLab == null ? 1 : lastLab.Id + 1;
        lab.Id = labId;

        await _labs.InsertOneAsync(lab);
        return lab;
    }

    public async Task<Boolean> UpdateLabAsync(int id, Lab updatedLab)
    {
        // skip the Id , PEE, Instructors, and Students fields
        var updateDefinition = new List<UpdateDefinition<Lab>>();
        var builder = Builders<Lab>.Update;

        var restrictedFields = new HashSet<string> { "Id", "PPE", "Instructors", "Students", "EndLab", "Announcements", "Started", "Report" };

        foreach (var prop in updatedLab.GetType().GetProperties())
        {
            var value = prop.GetValue(updatedLab);

            if (value != null && !restrictedFields.Contains(prop.Name))
            {
                var fieldName = prop.Name;
                // check if semester exists in the database
                if (fieldName == "SemesterID" && await _semesterService.GetSemesterByIdAsync((int)value) == null && (int)value != 0)
                    continue;
                var fieldUpdate = builder.Set(fieldName, value);
                updateDefinition.Add(fieldUpdate);
            }
        }

        var result = await _labs.UpdateOneAsync(lab => lab.Id == id, builder.Combine(updateDefinition));

        return result.ModifiedCount > 0;

    }

    public async Task<List<int>> AddStudentToLabAsync(int labId, List<String> emails)
    {
        foreach (var email in emails)
        {
            var student = await _userService.GetUserByEmailAsync(email);
            if (student == null)
            {
                bool create_student = _labHelper.CreateStudentIfNotExists(email);
                if (!create_student)
                    return [];
            }
        }
        List<int> studentsId = [];
        foreach (var email in emails)
        {
            var student = await _userService.GetUserByEmailAsync(email);
            studentsId.Add(student.Id);
        }
        var updateDefinition = Builders<Lab>.Update.PushEach(lab => lab.Students, studentsId);
        var result = await _labs.UpdateOneAsync(lab => lab.Id == labId, updateDefinition);

        return result.ModifiedCount > 0 ? studentsId : [];
    }

    public async Task<Boolean> AddInstructorToLabAsync(int labId, List<int> instructorIds)
    {
        var updateDefinition = Builders<Lab>.Update.PushEach(lab => lab.Instructors, instructorIds);
        var result = await _labs.UpdateOneAsync(lab => lab.Id == labId, updateDefinition);

        return result.ModifiedCount > 0;
    }

    public async Task<Boolean> EditPPEOfLabAsync(int labId, List<int> ppeId)
    {
        var updateDefinition = Builders<Lab>.Update.Set(lab => lab.PPE, ppeId);
        var result = await _labs.UpdateOneAsync(lab => lab.Id == labId, updateDefinition);

        return result.ModifiedCount > 0;
    }

    public async Task<Boolean> RemoveStudentFromLabAsync(int labId, int studentId)
    {
        var updateDefinition = Builders<Lab>.Update.Pull(lab => lab.Students, studentId);
        var result = await _labs.UpdateOneAsync(lab => lab.Id == labId, updateDefinition);

        return result.ModifiedCount > 0;
    }

    public async Task<Boolean> RemoveInstructorFromLabAsync(int labId, int instructorId)
    {
        var updateDefinition = Builders<Lab>.Update.Pull(lab => lab.Instructors, instructorId);
        var result = await _labs.UpdateOneAsync(lab => lab.Id == labId, updateDefinition);

        return result.ModifiedCount > 0;
    }

    public async Task<Boolean> DeleteLabAsync(int id)
    {
        var result = await _labs.DeleteOneAsync(lab => lab.Id == id);
        return result.DeletedCount > 0;
    }

    public async Task<Boolean> EndLabAsync(int id)
    {
        var updateDefinition = Builders<Lab>.Update.Set(lab => lab.EndLab, true);
        var result = await _labs.UpdateOneAsync(lab => lab.Id == id, updateDefinition);

        return result.ModifiedCount > 0;
    }

    public async Task<AnnouncementDTO?> SendAnnouncementToLabAsync(int id, Announcement announcement, IFormFileCollection? files)
    {
        var lab = await GetLabByIdAsync(id);
        if (lab == null)
        {
            return null;
        }
        var last_announcement = lab.Announcements.OrderByDescending(a => a.Id).FirstOrDefault();
        announcement.Id = last_announcement == null ? 1 : last_announcement.Id + 1;
        announcement.Time = DateTime.UtcNow;
        // handle files upload
        var currentDirectory = AppContext.BaseDirectory;
        var directoryPath = Path.Combine(currentDirectory, "wwwroot", "files");
        if (!Directory.Exists(directoryPath))
        {
            Directory.CreateDirectory(directoryPath);
        }
        if (files != null)
        {

            var files_paths = new List<string>();
            foreach (var file in files)
            {
                var timestamp = DateTime.Now.ToString("yyyyMMddHHmmssffff");
                var new_file_name = $"{file.FileName}_{timestamp}.{file.FileName.Split('.').Last()}";
                var file_path = $"files/{new_file_name}";
                using (var stream = new FileStream(Path.Combine(directoryPath, new_file_name), FileMode.Create))
                {
                    await file.CopyToAsync(stream);
                }
                if (file_path != null)
                    files_paths.Add(file_path);
            }
            announcement.Files = files_paths;
        }
        var updateDefinition = Builders<Lab>.Update.Push(lab => lab.Announcements, announcement);
        var result = await _labs.UpdateOneAsync(lab => lab.Id == id, updateDefinition);

        await _notificationService.SendNotificationAsync(new NotificationModel
        {
            Title = $"{lab.LabName} Announcement",
            Body = announcement.Message,
            Data = new Dictionary<string, string> { { "lab_id", id.ToString() } },
            TargetFcmTokens = lab.Students.Select(studentId => _userService.GetUserById(studentId).Result.FcmToken).Where(token => token != null).Cast<string>().ToList()
        });

        AnnouncementDTO announcementDTO = new AnnouncementDTO
        {
            Id = announcement.Id,
            user = (UserDTO)await _userService.GetUserById(announcement.Sender),
            Message = announcement.Message,
            Files = announcement.Files,
            Time = announcement.Time,
            Comments = []
        };

        return result.ModifiedCount > 0 ? announcementDTO : null;
    }

    public async Task<string> DeleteAnnouncementFromLabAsync(int lab_id, int announcementId, int user_id)
    {
        // check if the user is the sender of the announcement
        var lab = await GetLabByIdAsync(lab_id);
        var announcement = lab.Announcements.Find(a => a.Id == announcementId);
        if (announcement == null || announcement.Sender != user_id)
        {
            return "You are not the sender of the announcement";
        }
        var updateDefinition = Builders<Lab>.Update.PullFilter(lab => lab.Announcements, announcement => announcement.Id == announcementId);
        var result = await _labs.UpdateOneAsync(lab => lab.Id == lab_id, updateDefinition);

        return result.ModifiedCount > 0 ? "success" : "Announcement not found";
    }

    public async Task<CommentDTO?> CommentOnAnnouncementAsync(int lab_id, int announcementId, Comment comment)
    {
        var lab = await GetLabByIdAsync(lab_id);
        var announcement = lab.Announcements.Find(a => a.Id == announcementId);
        if (announcement == null)
        {
            return null;
        }
        var last_comment = announcement.Comments.OrderByDescending(c => c.Id).FirstOrDefault();
        comment.Id = last_comment == null ? 1 : last_comment.Id + 1;
        comment.Time = DateTime.UtcNow;
        var updateDefinition = Builders<Lab>.Update.Push("Announcements.$[a].Comments", comment);
        var arrayFilters = new List<ArrayFilterDefinition>
        {
            new BsonDocumentArrayFilterDefinition<BsonDocument>(new BsonDocument("a._id", announcementId))
        };
        var result = await _labs.UpdateOneAsync(lab => lab.Id == lab_id, updateDefinition, new UpdateOptions { ArrayFilters = arrayFilters });

        await _notificationService.SendNotificationAsync(new NotificationModel
        {
            Title = $"{lab.LabName} comment",
            Body = comment.Message,
            Data = new Dictionary<string, string> { { "lab_id", lab_id.ToString() } },
            TargetFcmTokens = lab.Instructors.Select(instructorId => _userService.GetUserById(instructorId).Result.FcmToken).Where(token => token != null).Cast<string>().ToList()
        });

        CommentDTO commentDTO = new()
        {
            Id = comment.Id,
            user = (UserDTO)await _userService.GetUserById(comment.Sender),
            Message = comment.Message,
            Time = comment.Time
        };

        return result.ModifiedCount > 0 ? commentDTO : null;

    }

    public async Task<Comment?> GetCommentByIdAsync(int lab_id, int announcementId, int commentId)
    {
        var lab = await GetLabByIdAsync(lab_id);
        var announcement = lab.Announcements.Find(a => a.Id == announcementId);
        if (announcement == null)
        {
            return null;
        }
        return announcement.Comments.Find(c => c.Id == commentId);
    }

    public async Task<Boolean> DeleteCommentFromAnnouncementAsync(int lab_id, int announcementId, int commentId)
    {
        var updateDefinition = Builders<Lab>.Update.PullFilter("Announcements.$[a].Comments", Builders<Comment>.Filter.Eq(comment => comment.Id, commentId));
        var arrayFilters = new List<ArrayFilterDefinition>
        {
            new BsonDocumentArrayFilterDefinition<BsonDocument>(new BsonDocument("a._id", announcementId))
        };
        var result = await _labs.UpdateOneAsync(lab => lab.Id == lab_id, updateDefinition, new UpdateOptions { ArrayFilters = arrayFilters });

        return result.ModifiedCount > 0;
    }

    public async Task<List<AnnouncementDTO>> GetAnnouncementsAsync(int lab_id)
    {
        var lab = await GetLabByIdAsync(lab_id);
        var announcements = new List<AnnouncementDTO>();
        foreach (var announcement in lab.Announcements)
        {
            var sender = (UserDTO)await _userService.GetUserById(announcement.Sender);
            var comments = new List<CommentDTO>();
            foreach (var comment in announcement.Comments)
            {
                var comment_sender = (UserDTO)await _userService.GetUserById(comment.Sender);
                comments.Add(new CommentDTO
                {
                    Id = comment.Id,
                    user = comment_sender,
                    Message = comment.Message,
                    Time = comment.Time
                });
            }
            announcements.Add(new AnnouncementDTO
            {
                Id = announcement.Id,
                user = sender,
                Message = announcement.Message,
                Files = announcement.Files,
                Time = announcement.Time,
                Comments = comments,
                Assignment = announcement.Assignment,
                CanSubmit = announcement.CanSubmit,
                Deadline = announcement.Deadline,
                Submissions = SubmissionDTO.FromSubmissionAsync(announcement.Submissions, _userService).Result,
                Grade = announcement.Grade
            });
        }
        return announcements;
    }

    public async Task<OneOf<Sessions, ErrorMessage>> StartSessionAsync(int lab_id)
    {
        var lab = await GetLabByIdAsync(lab_id);

        if (lab.Started)
        {
            return new ErrorMessage { StatusCode = 400, Message = "lab is already started" };
        }

        // check if the lab is in schedule
        var currentDay = DateTime.Now.ToString("dddd", new CultureInfo("en-US"));
        // get Eastern European Standard Time time zone
        TimeZoneInfo eetTimeZone = TimeZoneInfo.FindSystemTimeZoneById("Europe/Helsinki");
        DateTime utcNow = DateTime.UtcNow;
        DateTime currentTime = TimeZoneInfo.ConvertTimeFromUtc(utcNow, eetTimeZone);
        var currentTimeOnly = TimeOnly.FromDateTime(currentTime);
        // var currentTime = TimeOnly.FromDateTime(DateTime.Now.AddMinutes(-5));
        foreach (var labTime in lab.Schedule)
        {
            if (labTime.DayOfWeek == currentDay && labTime.StartTime <= currentTimeOnly && labTime.EndTime > currentTimeOnly)
            {
                Sessions session = await _sessionService.CreateSessionAsync(lab_id);
                var updateDefinition = Builders<Lab>.Update.Set(l => l.Started, true);
                var ppe_list = await _ppeService.GetListOfPPEsAsync(lab.PPE);
                var ppe_names = ppe_list.Select(ppe => ppe.Name).ToList();
                var message = new { ppe_arr = ppe_names, session_id = session.Id, lab_id = lab_id, room = lab.Room, command = "start" };
                var kafka = await _kafkaProducer.ProduceAsync("recording_se", JsonSerializer.Serialize(message));
                if (!kafka.success) return new ErrorMessage { StatusCode = 500, Message = "Connection error" };
                await _labs.UpdateOneAsync(l => l.Id == lab_id, updateDefinition);
                return session;
            }
        }

        return new ErrorMessage { StatusCode = 400, Message = "lab is not in schedule" };
    }

    public async Task<OneOf<bool, ErrorMessage>> EndSessionAsync(int lab_id)
    {
        var lab = await GetLabByIdAsync(lab_id);

        if (!lab.Started)
        {
            return new ErrorMessage { StatusCode = 400, Message = "lab is not started" };
        }

        var kafka = await _kafkaProducer.ProduceAsync("recording_se", JsonSerializer.Serialize(new { lab_id = lab.Id, room = lab.Room, command = "end" }));
        if (!kafka.success) return new ErrorMessage { StatusCode = 500, Message = "Connection error" };
        var updateDefinition = Builders<Lab>.Update.Set(l => l.Started, false);
        await _labs.UpdateOneAsync(l => l.Id == lab_id, updateDefinition);

        return true;
    }

    public async Task<List<Lab>> GetLabsByRoomAsync(string room)
    {
        return await _labs.Find(l => l.Room == room && l.EndLab == false).ToListAsync();
    }

    public async Task<Dictionary<string, object>> AnalyzeLabAsync(int lab_id, string role, int id)
    {
        var lab = await GetLabByIdAsync(lab_id);
        var result = new Dictionary<string, object>();
        var sessions = await _sessionService.GetSessionsOfLabAsync(lab_id);
        if (sessions == null || sessions.Count == 0)
            return result;
        // sort the sessions by date
        sessions.Sort((a, b) => a.Date.CompareTo(b.Date));

        int total_attendance = 0;
        List<int> total_attendance_bysession = [];
        List<string> xaxis = [];

        var ppe_compliance = new Dictionary<string, int>();
        Dictionary<string, List<int>> ppe_compliance_bysesions = [];
        Dictionary<string, int> count_of_ppe = [];

        int total_ppe_compliance = 0;
        List<int> total_ppe_compliance_bysession = [];
        List<int> st_total_ppe_compliance_bysession = [];

        List<ObjectResultDTO> people = [];
        Dictionary<int, int> people_attandance = [];
        List<object> people_bysession = [];
        // loop over all sessions
        foreach (var session in sessions)
        {
            if (role == "student")
            {
                var person = session.Result.Find(p => p.Id == id);
                if (person != null)
                {
                    total_attendance += person!.Attendance_percentage;
                    total_attendance_bysession.Add(person!.Attendance_percentage);
                }
                else
                {
                    total_attendance += 0;
                    total_attendance_bysession.Add(0);
                }

            }
            else
            {
                total_attendance += session.TotalAttendance;
                total_attendance_bysession.Add(session.TotalAttendance);
            }
            xaxis.Add(session.Date.ToString());
            // loop over all ppe in the session
            foreach (var ppe in session.TotalPPECompliance)
            {
                if (ppe_compliance.ContainsKey(ppe.Key))
                {
                    ppe_compliance[ppe.Key] += ppe.Value;
                    ppe_compliance_bysesions[ppe.Key].Add(ppe.Value);
                    count_of_ppe[ppe.Key] += 1;
                }
                else
                {
                    ppe_compliance[ppe.Key] = ppe.Value;
                    ppe_compliance_bysesions[ppe.Key] = [ppe.Value];
                    count_of_ppe[ppe.Key] = 1;
                }
            }
            if (session.TotalPPECompliance.Count != 0)
            {
                total_ppe_compliance += session.TotalPPECompliance.Sum(ppe => ppe.Value) / session.TotalPPECompliance.Count;
                total_ppe_compliance_bysession.Add(session.TotalPPECompliance.Sum(ppe => ppe.Value) / session.TotalPPECompliance.Count);
            }
            // loop over all people in the session
            if (role == "student")
            {
                var person = session.Result.Find(p => p.Id == id);
                if (person != null)
                {
                    if (people.Any(p => p.Id == id))
                    {
                        people_attandance[person.Id] += 1;
                        var p = people.Find(p => p.Id == id);
                        var p_bytime = people_bysession.Find(p => ((dynamic)p).Id == id);
                        p!.Attendance_percentage += person.Attendance_percentage;
                        ((dynamic)p_bytime!).Attendance_percentage.Add(person.Attendance_percentage);
                        var temp_total_ppe_compliance = 0;
                        foreach (var ppe in person.PPE_compliance)
                        {
                            if (p.PPE_compliance.ContainsKey(ppe.Key))
                            {

                                p.PPE_compliance[ppe.Key] += ppe.Value;
                                ((dynamic)p_bytime!).PPE_compliance[ppe.Key].Add(ppe.Value);
                            }
                            else
                            {
                                p.PPE_compliance[ppe.Key] = ppe.Value;
                                ((dynamic)p_bytime!).PPE_compliance[ppe.Key] = new List<int> { ppe.Value };
                            }
                            temp_total_ppe_compliance += ppe.Value;
                        }
                        if (person.PPE_compliance.Count != 0)
                            temp_total_ppe_compliance /= person.PPE_compliance.Count;
                        st_total_ppe_compliance_bysession.Add(temp_total_ppe_compliance);


                    }
                    else
                    {
                        people.Add(person);
                        people_attandance[person.Id] = 1;
                        var temp_ppe_compliance = new Dictionary<string, List<int>>();
                        foreach (var ppe in person.PPE_compliance)
                        {
                            temp_ppe_compliance[ppe.Key] = [ppe.Value];
                        }
                        var p = new
                        {
                            Id = person.Id,
                            Name = person.Name,
                            user = person.User,
                            Attendance_percentage = new List<int> { person.Attendance_percentage },
                            PPE_compliance = temp_ppe_compliance
                        };
                        people_bysession.Add(p);
                    }
                }
            }
            else
            {

                foreach (var person in session.Result)
                {
                    // check if the person is already in the people list
                    if (people.Any(p => p.Id == person.Id))
                    {
                        people_attandance[person.Id] += 1;
                        var p = people.Find(p => p.Id == person.Id);
                        var p_bytime = people_bysession.Find(p => ((dynamic)p).Id == person.Id);
                        p!.Attendance_percentage += person.Attendance_percentage;
                        ((dynamic)p_bytime!).Attendance_percentage.Add(person.Attendance_percentage);
                        foreach (var ppe in person.PPE_compliance)
                        {
                            if (p.PPE_compliance.ContainsKey(ppe.Key))
                            {
                                p.PPE_compliance[ppe.Key] += ppe.Value;
                                ((dynamic)p_bytime!).PPE_compliance[ppe.Key].Add(ppe.Value);
                            }
                            else
                            {
                                p.PPE_compliance[ppe.Key] = ppe.Value;
                                ((dynamic)p_bytime!).PPE_compliance[ppe.Key] = new List<int> { ppe.Value };
                            }
                        }

                    }
                    else
                    {
                        people.Add(person);
                        people_attandance[person.Id] = 1;
                        var temp_ppe_compliance = new Dictionary<string, List<int>>();
                        foreach (var ppe in person.PPE_compliance)
                        {
                            temp_ppe_compliance[ppe.Key] = [ppe.Value];
                        }
                        var p = new
                        {
                            Id = person.Id,
                            Name = person.Name,
                            user = person.User,
                            Attendance_percentage = new List<int> { person.Attendance_percentage },
                            PPE_compliance = temp_ppe_compliance
                        };
                        people_bysession.Add(p);
                    }
                }
            }
        }

        // calculate the average of the ppe compliance
        if (role == "student")
        {
            if (people.Count != 0)
                ppe_compliance = people[0].PPE_compliance;
            else
                ppe_compliance = [];

            if (people_bysession.Count != 0)
                ppe_compliance_bysesions = ((dynamic)people_bysession[0]).PPE_compliance;
            else
                ppe_compliance_bysesions = [];

        }
        foreach (var ppe in ppe_compliance)
        {
            if (count_of_ppe[ppe.Key] != 0)
                ppe_compliance[ppe.Key] /= count_of_ppe[ppe.Key];
        }
        // calculate the average of people attendance and ppe compliance
        foreach (var person in people)
        {
            person.Attendance_percentage /= sessions.Count;
            foreach (var ppe in person.PPE_compliance)
            {
                if (people_attandance[person.Id] != 0)
                    person.PPE_compliance[ppe.Key] /= people_attandance[person.Id];
            }
        }
        if (role == "student")
        {
            if (people.Count != 0)
            {
                people_attandance[people[0].Id] = people_attandance[people[0].Id] != 0 ? people_attandance[people[0].Id] : 1;
                total_ppe_compliance /= people_attandance[people[0].Id];
            }
            else
            {
                people_attandance = [];
                total_ppe_compliance = 0;
                total_ppe_compliance_bysession = st_total_ppe_compliance_bysession;
            }
        }
        int sessions_count = sessions.Count != 0 ? sessions.Count : 1;
        // save the result in the dictionary
        result["lab_id"] = lab_id;
        result["lab_name"] = lab.LabName;
        result["total_attendance"] = total_attendance /= sessions_count;
        result["total_attendance_bytime"] = total_attendance_bysession;
        result["total_ppe_compliance"] = total_ppe_compliance /= sessions_count;
        result["total_ppe_compliance_bytime"] = total_ppe_compliance_bysession;
        result["ppe_compliance"] = ppe_compliance;
        result["ppe_compliance_bytime"] = ppe_compliance_bysesions;
        result["people"] = people;
        result["people_bytime"] = people_bysession;
        result["xaxis"] = xaxis;

        return result;
    }

    public async Task<AnnouncementDTO?> SubmitSolutionToAssignmentAsync(int lab_id, int assignment_id, Submission submission, IFormFileCollection? files)
    {
        var lab = await GetLabByIdAsync(lab_id);
        if (lab == null)
            return null;

        var assignment = lab.Announcements.Find(a => a.Id == assignment_id);
        if (assignment == null || !assignment.Assignment)
            return null;

        submission.Time = DateTime.UtcNow;
        submission.Submitted = true;

        // handle files upload
        var currentDirectory = AppContext.BaseDirectory;
        var directoryPath = Path.Combine(currentDirectory, "wwwroot", "files");
        if (!Directory.Exists(directoryPath))
        {
            Directory.CreateDirectory(directoryPath);
        }
        if (files != null)
        {

            var files_paths = new List<string>();
            foreach (var file in files)
            {
                var timestamp = DateTime.Now.ToString("yyyyMMddHHmmssffff");
                var new_file_name = $"{file.FileName}_{timestamp}.{file.FileName.Split('.').Last()}";
                var file_path = $"files/{new_file_name}";
                using (var stream = new FileStream(Path.Combine(directoryPath, new_file_name), FileMode.Create))
                {
                    await file.CopyToAsync(stream);
                }
                if (file_path != null)
                    files_paths.Add(file_path);
            }
            submission.Files = files_paths;
        }
        // save the assignment 
        var updateDefinition = Builders<Lab>.Update.Push("Announcements.$[a].Submissions", submission);
        var arrayFilters = new List<ArrayFilterDefinition>
        {
            new BsonDocumentArrayFilterDefinition<BsonDocument>(new BsonDocument("a._id", assignment_id))
        };
        var result = await _labs.UpdateOneAsync(l => l.Id == lab_id, updateDefinition, new UpdateOptions { ArrayFilters = arrayFilters });

        if (result.ModifiedCount == 0)
            return null;

        assignment.Submissions.Add(submission);

        AnnouncementDTO assignmentDTO = new AnnouncementDTO
        {
            Id = assignment.Id,
            user = (UserDTO)await _userService.GetUserById(assignment.Sender),
            Message = assignment.Message,
            Files = assignment.Files,
            Time = assignment.Time,
            Comments = CommentDTO.FromCommentListAsync(assignment.Comments, _userService).Result,
            Assignment = assignment.Assignment,
            CanSubmit = assignment.CanSubmit,
            Deadline = assignment.Deadline,
            Submissions = SubmissionDTO.FromSubmissionAsync(assignment.Submissions, _userService).Result,
            Grade = assignment.Grade
        };

        return result.ModifiedCount > 0 ? assignmentDTO : null;
    }

    public async Task<bool> SetGradeAsync(int lab_id, int assignment_id, int user_id, int grade)
    {
        var lab = await GetLabByIdAsync(lab_id);
        if (lab == null)
            return false;

        var assignment = lab.Announcements.Find(a => a.Id == assignment_id);
        if (assignment == null || !assignment.Assignment)
            return false;

        var submission = assignment.Submissions.Find(s => s.UserId == user_id);
        if (submission == null)
            return false;

        submission.Grade = grade;

        var updateDefinition = Builders<Lab>.Update.Set("Announcements.$[a].Submissions.$[s].Grade", grade);
        var arrayFilters = new List<ArrayFilterDefinition>
        {
            new BsonDocumentArrayFilterDefinition<BsonDocument>(new BsonDocument("a._id", assignment_id)),
            new BsonDocumentArrayFilterDefinition<BsonDocument>(new BsonDocument("s.UserId", submission.UserId))
        };
        var result = await _labs.UpdateOneAsync(l => l.Id == lab_id, updateDefinition, new UpdateOptions { ArrayFilters = arrayFilters });

        return result.ModifiedCount > 0;
    }

}
