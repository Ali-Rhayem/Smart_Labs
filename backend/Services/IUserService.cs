using backend.Models;
using OneOf;

namespace backend.Services
{
    public interface IUserService
    {
        Task<List<User>> GetAllUsers();
        Task<User?> GetUserById(int id);
        Task<User?> GetWholeUserById(int id);
        Task<User?> CreateUser(User user);
        Task<OneOf<User, ErrorMessage>> UpdateUser(int id, UpdateUser updatedFields);
        Task<bool> DeleteUser(int id);
        Task<User> GetUserByEmailAsync(string email);
        Task<User> GetUserByFcmTokenAsync(string fcmToken);
        Task<bool> SaveFcmToken(int id, string fcmToken);
        Task<User?> FirstLoginAsync(FirstLogin firstLogin);
        Task<bool> ChangePassword(int id, string newPassword);
        Task<bool> ResetPasswordAsync(int id);
    }
}