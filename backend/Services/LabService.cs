using backend.helpers;
using backend.Models;
using MongoDB.Driver;
using backend.Services;
using OneOf;
using System.Globalization;
using MongoDB.Bson;
using System.Text.Json;

public class LabService
{
    private readonly IMongoCollection<Lab> _labs;
    private readonly LabHelper _labHelper;
    private readonly UserService _userService;
    private readonly SemesterService _semesterService;
    private readonly PPEService _ppeService;
    private readonly SessionService _sessionService;
    private readonly KafkaProducer _kafkaProducer;

    public LabService(IMongoDatabase database, LabHelper labHelper, UserService userService, SemesterService semesterService, PPEService ppeService, SessionService sessionService, KafkaProducer kafkaProducer)
    {
        _labs = database.GetCollection<Lab>("Labs");
        _labHelper = labHelper;
        _userService = userService;
        _semesterService = semesterService;
        _ppeService = ppeService;
        _sessionService = sessionService;
        _kafkaProducer = kafkaProducer;
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
            students.Add(student);
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
            instructors.Add(instructor);
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

        var restrictedFields = new HashSet<string> { "Id", "PPE", "Instructors", "Students" };

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

    public async Task<Boolean> AddStudentToLabAsync(int labId, List<String> emails)
    {
        foreach (var email in emails)
        {
            var student = await _userService.GetUserByEmailAsync(email);
            if (student == null)
            {
                bool create_student = _labHelper.CreateStudentIfNotExists(email);
                if (!create_student)
                    return false;
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

        return result.ModifiedCount > 0;
    }

    public async Task<Boolean> AddInstructorToLabAsync(int labId, int instructorId)
    {
        var updateDefinition = Builders<Lab>.Update.Push(lab => lab.Instructors, instructorId);
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

    public async Task<Boolean> SendAnnouncementToLabAsync(int id, Announcement announcement)
    {
        var lab = await GetLabByIdAsync(id);
        if (lab == null)
        {
            return false;
        }
        var last_announcement = lab.Announcements.OrderByDescending(a => a.Id).FirstOrDefault();
        announcement.Id = last_announcement == null ? 1 : last_announcement.Id + 1;
        var updateDefinition = Builders<Lab>.Update.Push(lab => lab.Announcements, announcement);
        var result = await _labs.UpdateOneAsync(lab => lab.Id == id, updateDefinition);

        return result.ModifiedCount > 0;
    }

    public async Task<Boolean> DeleteAnnouncementFromLabAsync(int lab_id, int announcementId)
    {
        var updateDefinition = Builders<Lab>.Update.PullFilter(lab => lab.Announcements, announcement => announcement.Id == announcementId);
        var result = await _labs.UpdateOneAsync(lab => lab.Id == lab_id, updateDefinition);

        return result.ModifiedCount > 0;
    }

    public async Task<Boolean> CommentOnAnnouncementAsync(int lab_id, int announcementId, Comment comment)
    {
        var lab = await GetLabByIdAsync(lab_id);
        var announcement = lab.Announcements.Find(a => a.Id == announcementId);
        if (announcement == null)
        {
            return false;
        }
        var last_comment = announcement.Comments.OrderByDescending(c => c.Id).FirstOrDefault();
        comment.Id = last_comment == null ? 1 : last_comment.Id + 1;
        var updateDefinition = Builders<Lab>.Update.Push("Announcements.$[a].Comments", comment);
        var arrayFilters = new List<ArrayFilterDefinition>
        {
            new BsonDocumentArrayFilterDefinition<BsonDocument>(new BsonDocument("a.Id", announcementId))
        };
        var result = await _labs.UpdateOneAsync(lab => lab.Id == lab_id, updateDefinition, new UpdateOptions { ArrayFilters = arrayFilters });

        return result.ModifiedCount > 0;

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
            new BsonDocumentArrayFilterDefinition<BsonDocument>(new BsonDocument("a.Id", announcementId))
        };
        var result = await _labs.UpdateOneAsync(lab => lab.Id == lab_id, updateDefinition, new UpdateOptions { ArrayFilters = arrayFilters });

        return result.ModifiedCount > 0;
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
        var currentTime = TimeOnly.FromDateTime(DateTime.Now.AddMinutes(-5));
        foreach (var labTime in lab.Schedule)
        {
            Console.WriteLine(currentTime);
            Console.WriteLine(labTime.StartTime);
            if (labTime.DayOfWeek == currentDay && labTime.StartTime <= currentTime && labTime.EndTime > currentTime)
            {
                Sessions session = await _sessionService.CreateSessionAsync(lab_id);
                var updateDefinition = Builders<Lab>.Update.Set(l => l.Started, true);
                var ppe_list = await _ppeService.GetListOfPPEsAsync(lab.PPE);
                var ppe_names = ppe_list.Select(ppe => ppe.Name).ToList();
                await _labs.UpdateOneAsync(l => l.Id == lab_id, updateDefinition);
                var message = new { ppe_arr = ppe_names, session_id = session.Id, lab_id = lab_id, room = lab.Room, status = "start" };
                await _kafkaProducer.ProduceAsync("Lab_rooms", JsonSerializer.Serialize(message));
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

        await _kafkaProducer.ProduceAsync("Lab_rooms", JsonSerializer.Serialize(new { room = lab.Room, status = "end" }));
        var updateDefinition = Builders<Lab>.Update.Set(l => l.Started, false);
        await _labs.UpdateOneAsync(l => l.Id == lab_id, updateDefinition);

        return true;
    }

}
