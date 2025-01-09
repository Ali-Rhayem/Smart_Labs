using backend.helpers;
using backend.Models;
using MongoDB.Driver;

public class LabService
{
    private readonly IMongoCollection<Lab> _labs;
    private readonly IMongoCollection<User> _users;
    private readonly LabHelper _labHelper;

    public LabService(IMongoDatabase database, LabHelper labHelper)
    {
        _labs = database.GetCollection<Lab>("Labs");
        _users = database.GetCollection<User>("Users");
        _labHelper = labHelper;
    }

    public async Task<List<Lab>> GetAllLabsAsync()
    {
        return await _labs.Find(_ => true).ToListAsync();
    }

    public async Task<List<Lab>> GetInstructorLabsAsync(int instructorId)
    {
        return await _labs.Find(lab => lab.Instructors.Contains(instructorId)).ToListAsync();
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

    public async Task<Boolean> AddStudentToLabAsync(int labId, int studentId)
    {
        // Check if student exists in the database
        var student = await _users.Find(user => user.Id == studentId).FirstOrDefaultAsync();

        if (student == null)
        {
            _labHelper.CreateStudentIfNotExists(studentId);
        }

        var updateDefinition = Builders<Lab>.Update.Push(lab => lab.Students, studentId);
        var result = await _labs.UpdateOneAsync(lab => lab.Id == labId, updateDefinition);

        return result.ModifiedCount > 0;
    }

    public async Task<Boolean> AddInstructorToLabAsync(int labId, int instructorId)
    {
        var updateDefinition = Builders<Lab>.Update.Push(lab => lab.Instructors, instructorId);
        var result = await _labs.UpdateOneAsync(lab => lab.Id == labId, updateDefinition);

        return result.ModifiedCount > 0;
    }

    public async Task<Boolean> AddPPEToLabAsync(int labId, int ppeId)
    {
        var updateDefinition = Builders<Lab>.Update.Push(lab => lab.PPE, ppeId);
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

    public async Task<Boolean> RemovePPEFromLabAsync(int labId, int ppeId)
    {
        var updateDefinition = Builders<Lab>.Update.Pull(lab => lab.PPE, ppeId);
        var result = await _labs.UpdateOneAsync(lab => lab.Id == labId, updateDefinition);

        return result.ModifiedCount > 0;
    }

    public async Task DeleteLabAsync(int id)
    {
        await _labs.DeleteOneAsync(lab => lab.Id == id);
    }
}
