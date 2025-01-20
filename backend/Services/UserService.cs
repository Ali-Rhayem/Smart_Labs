using MongoDB.Driver;
using backend.Models;

namespace backend.Services;

public class UserService
{
    private readonly IMongoCollection<User> _users;

    public UserService(IMongoDatabase database)
    {
        _users = database.GetCollection<User>("Users");
    }

    // for testing purposes
    public async Task<User> CreateUser(User user)
    {
        await _users.InsertOneAsync(user);
        return user;
    }

    // for testing purposes
    public async Task<List<User>> GetAllUsers()
    {
        var projection = Builders<User>.Projection
            .Exclude(u => u.Password)
            .Exclude(u => u.Role)
            .Exclude(u => u.FaceIdentityVector);

        return await _users.Find(_ => true).Project<User>(projection).ToListAsync();
    }

    public async Task<User> GetUserById(int id)
    {
        var projection = Builders<User>.Projection
            .Exclude(u => u.Password)
            .Exclude(u => u.FaceIdentityVector);

        return await _users
            .Find(user => user.Id == id).Project<User>(projection).FirstOrDefaultAsync();
    }

    public async Task<bool> UpdateUser(int id, User updatedFields)
    {
        var updateDefinition = new List<UpdateDefinition<User>>();
        var builder = Builders<User>.Update;

        // restricted fields
        var restrictedFields = new HashSet<string> { "Id", "Email", "Password", "Role", "FaceIdentityVector" };

        foreach (var prop in updatedFields.GetType().GetProperties())
        {
            var value = prop.GetValue(updatedFields);

            if (value != null && !restrictedFields.Contains(prop.Name))
            {
                var fieldName = prop.Name;
                var fieldUpdate = builder.Set(fieldName, value);
                updateDefinition.Add(fieldUpdate);
            }
        }

        if (!updateDefinition.Any())
            return false;

        var update = Builders<User>.Update.Combine(updateDefinition);
        var result = await _users.UpdateOneAsync(user => user.Id == id, update);

        return result.IsAcknowledged && result.ModifiedCount > 0;
    }

    public async Task<bool> DeleteUser(int id)
    {
        var result = await _users.DeleteOneAsync(user => user.Id == id);
        return result.IsAcknowledged && result.DeletedCount > 0;
    }

    public async Task<User> GetUserByEmailAsync(string email)
    {
        var projection = Builders<User>.Projection.Exclude(u => u.FaceIdentityVector);
        return await _users.Find(u => u.Email == email).Project<User>(projection).FirstOrDefaultAsync();
    }

}
