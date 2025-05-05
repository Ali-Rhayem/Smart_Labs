using backend.Models;

namespace backend.Services
{
    public interface INotificationService
    {
        Task SendNotificationAsync(NotificationModel notification);
        Task<Notifications> GetNotificationByIdAsync(int notificationId);
        Task<List<Notifications>> GetNotificationsByUserIdAsync(int userId);
        Task MarkNotificationAsReadAsync(int notificationId);
        Task MarkNotificationAsDeletedAsync(int notificationId);
        Task MarkAllNotificationsAsReadAsync(int userId);
        Task MarkAllNotificationsAsDeletedAsync(int userId);
    }
}