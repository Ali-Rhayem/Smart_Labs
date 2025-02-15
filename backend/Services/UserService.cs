using MongoDB.Driver;
using backend.Models;
using OneOf;
using System.ComponentModel.DataAnnotations;
using backend.helpers;

namespace backend.Services;

public class UserService
{
    private readonly IMongoCollection<User> _users;
    private readonly IMongoCollection<UpdateUser> _UpdateUser;
    private readonly FacultyService _facultyService;
    private readonly LabHelper _labHelper;

    public UserService(IMongoDatabase database, FacultyService facultyService, LabHelper labHelper)
    {
        _users = database.GetCollection<User>("Users");
        _UpdateUser = database.GetCollection<UpdateUser>("Users");
        _facultyService = facultyService;
        _labHelper = labHelper;
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
            .Exclude(u => u.Role);

        return await _users.Find(_ => true).Project<User>(projection).ToListAsync();
    }

    public async Task<User> GetUserById(int id)
    {
        var projection = Builders<User>.Projection
            .Exclude(u => u.Password);

        return await _users
            .Find(user => user.Id == id).Project<User>(projection).FirstOrDefaultAsync();
    }

    public async Task<User?> GetWholeUserById(int id)
    {
        return await _users.Find(user => user.Id == id).FirstOrDefaultAsync();
    }

    public async Task<OneOf<User, ErrorMessage>> UpdateUser(int id, UpdateUser updatedFields)
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
                    var email = value.ToString()!;
                    if (!new EmailAddressAttribute().IsValid(email))
                        return new ErrorMessage { StatusCode = 400, Message = "Invalid email address." };
                    var user_by_email = await GetUserByEmailAsync(value.ToString()!);
                    if (user_by_email != null && user_by_email.Id != id)
                        continue;
                }
                else if (fieldName == "faculty")
                {
                    var faculty = value as string;
                    if (faculty == null || !await _facultyService.FacultyExists(faculty))
                        return new ErrorMessage { StatusCode = 400, Message = "Invalid faculty." };
                }
                else if (fieldName == "major")
                {
                    var major = value as string;
                    if (major == null || !await _facultyService.MajorExistsInFaculty(updatedFields.Faculty, major))
                        return new ErrorMessage { StatusCode = 400, Message = "Invalid major or faculty." };
                }


                var fieldUpdate = builder.Set(fieldName, value);
                updateDefinition.Add(fieldUpdate);
            }
        }

        if (!updateDefinition.Any())
            return new ErrorMessage { StatusCode = 400, Message = "No fields to update." };

        var update = Builders<UpdateUser>.Update.Combine(updateDefinition);
        var result = await _UpdateUser.UpdateOneAsync(user => user.Id == id, update);

        var user = await GetUserById(id);
        return result.IsAcknowledged ? user : new ErrorMessage { StatusCode = 500, Message = "Update failed." };

    }

    public async Task<bool> DeleteUser(int id)
    {
        var result = await _users.DeleteOneAsync(user => user.Id == id);
        return result.IsAcknowledged && result.DeletedCount > 0;
    }

    public async Task<User> GetUserByEmailAsync(string email)
    {
        return await _users.Find(u => u.Email == email).FirstOrDefaultAsync();
    }

    public async Task<User> GetUserByFcmTokenAsync(string fcmToken)
    {
        var projection = Builders<User>.Projection.Exclude(u => u.Password);
        return await _users.Find(u => u.FcmToken == fcmToken).Project<User>(projection).FirstOrDefaultAsync();
    }

    public async Task<bool> SaveFcmToken(int id, string fcmToken)
    {
        var update = Builders<User>.Update.Set(u => u.FcmToken, fcmToken);
        var result = await _users.UpdateOneAsync(u => u.Id == id, update);
        return result.IsAcknowledged && result.ModifiedCount > 0;
    }

    public async Task<User?> FirstLoginAsync(FirstLogin firstLogin)
    {
        var image = firstLogin.Image;
        var imageType = image!.Split(';')[0].Split('/')[1];
        var imageBytes = Convert.FromBase64String(image.Split(',')[1]);
        var currentDirectory = AppContext.BaseDirectory;
        var directoryPath = Path.Combine(currentDirectory, "wwwroot", "medi");
        if (!Directory.Exists(directoryPath))
        {
            Directory.CreateDirectory(directoryPath);
        }
        var image_path = $"medi/{firstLogin.Id}.{imageType}";
        var SaveimagePath = Path.Combine(directoryPath, $"{firstLogin.Id}.{imageType}");
        await File.WriteAllBytesAsync(SaveimagePath, imageBytes);

        var user = await GetUserById(firstLogin.Id);
        var newUser = new User
        {
            Id = firstLogin.Id,
            Email = user.Email,
            Name = firstLogin.Name,
            Password = firstLogin.Password,
            Major = firstLogin.Major,
            Faculty = firstLogin.Faculty,
            Image = image_path,
            Role = user.Role,
            First_login = false
        };

        // update the user
        var builder = Builders<User>.Update;
        var update = builder.Set(u => u.First_login, false)
            .Set(u => u.Name, firstLogin.Name)
            .Set(u => u.Password, firstLogin.Password)
            .Set(u => u.Major, firstLogin.Major)
            .Set(u => u.Faculty, firstLogin.Faculty)
            .Set(u => u.Image, image_path);

        var result = await _users.UpdateOneAsync(u => u.Id == firstLogin.Id, update);
        return result.IsAcknowledged ? newUser : null;
    }

    public async Task<bool> ChangePassword(int id, string newPassword)
    {
        var update = Builders<User>.Update.Set(u => u.Password, BCrypt.Net.BCrypt.HashPassword(newPassword));
        var result = await _users.UpdateOneAsync(u => u.Id == id, update);
        return result.IsAcknowledged && result.ModifiedCount > 0;
    }

    public async Task<bool> ResetPasswordAsync(int id)
    {
        // generate a new password
        var password = _labHelper.GenerateTempPassword();
        // send email to user with the new password
        var user = await GetUserById(id);
        var subject = "Your Temporary Password";
        var message = "Dear User,\n\nYour temporary password is: " + password + "\n\nPlease log in and change your password immediately.\n\nBest regards,\nUniversity Team";
        bool send_email = _labHelper.SendEmail(user.Email, message, subject);
        if (!send_email)
        {
            return false;
        }

        // update the user
        var update = Builders<User>.Update.Set(u => u.Password, BCrypt.Net.BCrypt.HashPassword(password));
        var result = await _users.UpdateOneAsync(u => u.Id == id, update);
        return result.IsAcknowledged && result.ModifiedCount > 0;
    }
}
