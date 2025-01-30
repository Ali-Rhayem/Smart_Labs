using backend.helpers;
using backend.Models;
using MongoDB.Driver;
using backend.Services;
using OneOf;
using System.Globalization;

public class LabService
{
    private readonly IMongoCollection<Lab> _labs;
    private readonly IMongoCollection<User> _users;
    private readonly IMongoCollection<PPE> _ppes;
    private readonly LabHelper _labHelper;
    private readonly UserService _userService;
    private readonly SemesterService _semesterService;

    public LabService(IMongoDatabase database, LabHelper labHelper, UserService userService, SemesterService semesterService, PPEService ppeService)
    {
        _labs = database.GetCollection<Lab>("Labs");
        _users = database.GetCollection<User>("Users");
        _ppes = database.GetCollection<PPE>("PPE");
        _labHelper = labHelper;
        _userService = userService;
        _semesterService = semesterService;
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
            var ppe = await _ppes.Find(ppe => ppe.Id == ppeId).FirstOrDefaultAsync();
            if (ppe == null)
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
            var student = await _users.Find(user => user.Email == studentEmail).FirstOrDefaultAsync();
            if (student == null)
            {
                _labHelper.CreateStudentIfNotExists(studentEmail);
            }
        }
        List<int> student_ids = [];
        foreach (var studentEmail in student_emails)
        {
            var student = await _users.Find(user => user.Email == studentEmail).FirstOrDefaultAsync();
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
            var student = await _users.Find(user => user.Email == email).FirstOrDefaultAsync();
            if (student == null)
            {
                _labHelper.CreateStudentIfNotExists(email);
            }
        }
        List<int> studentsId = [];
        foreach (var email in emails)
        {
            var student = await _users.Find(user => user.Email == email).FirstOrDefaultAsync();
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
}
