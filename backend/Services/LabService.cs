using backend.helpers;
using backend.Models;
using MongoDB.Driver;
using backend.Services;

public class LabService
{
    private readonly IMongoCollection<Lab> _labs;
    private readonly IMongoCollection<User> _users;
    private readonly LabHelper _labHelper;
    private readonly UserService _userService;

    public LabService(IMongoDatabase database, LabHelper labHelper, UserService userService)
    {
        _labs = database.GetCollection<Lab>("Labs");
        _users = database.GetCollection<User>("Users");
        _labHelper = labHelper;
        _userService = userService;
    }

    public async Task<List<Lab>> GetAllLabsAsync()
    {
        return await _labs.Find(_ => true).ToListAsync();
    }

    public async Task<List<Lab>> GetInstructorLabsAsync(int instructorId)
    {
        return await _labs.Find(lab => lab.Instructors.Contains(instructorId)).ToListAsync();
    }

    public async Task<List<User>> GetStudentsInLabAsync(int labId)
    {
        var lab = await _labs.Find(lab => lab.Id == labId).FirstOrDefaultAsync();
        var students = new List<User>();
        foreach (var studentId in lab.Students)
        {
            var student = await _userService.GetUserById(studentId);
            students.Add(student);
        }
        return students;
    }

    public async Task<List<User>> GetInstructorsInLabAsync(int labId)
    {
        var lab = await _labs.Find(lab => lab.Id == labId).FirstOrDefaultAsync();
        var instructors = new List<User>();
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

    public async Task<Lab> CreateLabAsync(Lab lab)
    {
        // check if students exist in the database
        foreach (var studentId in lab.Students)
        {
            var student = await _users.Find(user => user.Id == studentId).FirstOrDefaultAsync();
            if (student == null)
            {
                _labHelper.CreateStudentIfNotExists(studentId);
            }
        }
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
                var fieldUpdate = builder.Set(fieldName, value);
                updateDefinition.Add(fieldUpdate);
            }
        }

        await _labs.UpdateOneAsync(lab => lab.Id == id, builder.Combine(updateDefinition));

        return true;

    }

    public async Task<Boolean> AddStudentToLabAsync(int labId, List<int> studentsId)
    {
        foreach (var id in studentsId)
        {
            var student = await _users.Find(user => user.Id == id).FirstOrDefaultAsync();
            if (student == null)
            {
                _labHelper.CreateStudentIfNotExists(id);
            }
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
