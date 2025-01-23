using MongoDB.Driver;
using backend.Models;

namespace backend.Services;

public class UserService
{
    private readonly IMongoCollection<User> _users;
    private readonly IMongoCollection<UpdateUser> _UpdateUser;

    public UserService(IMongoDatabase database)
    {
        _users = database.GetCollection<User>("Users");
        _UpdateUser = database.GetCollection<UpdateUser>("Users");
    }

    // for testing purposes
    public async Task<User?> CreateUser(User user)
    {
        var if_user = await GetUserByEmailAsync(user.Email);
        if (if_user != null && if_user.Id != user.Id)
            return null;
        var lastUser = _users.Find(_ => true).SortByDescending(user => user.Id).FirstOrDefault();
        var UserId = lastUser == null ? 1 : lastUser.Id + 1;
        user.Id = UserId;
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

    public async Task<User?> UpdateUser(int id, UpdateUser updatedFields)
    {
        var updateDefinition = new List<UpdateDefinition<UpdateUser>>();
        var builder = Builders<UpdateUser>.Update;

        foreach (var prop in updatedFields.GetType().GetProperties())
        {
            var value = prop.GetValue(updatedFields);

            if (value != null && prop.Name != "Id")
            {
                var fieldName = prop.Name;
                if (fieldName == "Image")
                {
                    var image = value as string;
                    var imageType = image!.Split(';')[0].Split('/')[1];
                    var imageBytes = Convert.FromBase64String(image.Split(',')[1]);
                    var currentDirectory = AppContext.BaseDirectory;
                    var directoryPath = Path.Combine(currentDirectory, "wwwroot", "medi");
                    if (!Directory.Exists(directoryPath))
                    {
                        Directory.CreateDirectory(directoryPath);
                    }
                    var image_path = $"medi/{id}.{imageType}";
                    var SaveimagePath = Path.Combine(directoryPath, $"{id}.{imageType}");
                    await File.WriteAllBytesAsync(SaveimagePath, imageBytes);
                    value = image_path;
                }
                else if (fieldName == "email")
                {
                    var user_by_email = await GetUserByEmailAsync(value.ToString()!);
                    if (user_by_email != null && user_by_email.Id != id)
                        continue;
                }

                var fieldUpdate = builder.Set(fieldName, value);
                updateDefinition.Add(fieldUpdate);
            }
        }

        if (!updateDefinition.Any())
            return null;

        var update = Builders<UpdateUser>.Update.Combine(updateDefinition);
        var result = await _UpdateUser.UpdateOneAsync(user => user.Id == id, update);

        var user = await GetUserById(id);
        return result.IsAcknowledged ? user : null;

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
