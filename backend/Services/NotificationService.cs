using backend.Models;
using FirebaseAdmin;
using FirebaseAdmin.Messaging;
using Google.Apis.Auth.OAuth2;
using Microsoft.IdentityModel.Protocols.Configuration;
using MongoDB.Driver;

namespace backend.Services;

public class NotificationService
{
    private readonly IMongoCollection<Notifications> _notifications;
    private readonly UserService _users;

    public NotificationService(IMongoDatabase database, UserService user)
    {
        _notifications = database.GetCollection<Notifications>("Notifications");
        _users = user;
    }

    public async Task SendNotificationAsync(NotificationModel notification)
    {
        var message = new MulticastMessage
        {
            Tokens = notification.TargetFcmTokens,
            Notification = new Notification
            {
                Title = notification.Title,
                Body = notification.Body
            },
            Data = notification.Data
        };

        var last_notification_id = _notifications.Find(Builders<Notifications>.Filter.Empty).SortByDescending(n => n.Id).FirstOrDefault()?.Id ?? 0;
        foreach (var token in notification.TargetFcmTokens)
        {
            last_notification_id += 1;
            User user = await _users.GetUserByFcmTokenAsync(token);
            if (user != null)
            {
                var save_notification = new Notifications
                {
                    Id = last_notification_id,
                    Title = notification.Title,
                    Message = notification.Body,
                    Data = notification.Data,
                    Date = DateTime.Now,
                    UserID = user.Id,
                };
                await _notifications.InsertOneAsync(save_notification);
            }

        }

        var response = await FirebaseMessaging.DefaultInstance.SendEachForMulticastAsync(message);

        Console.WriteLine("Successfully sent message: " + response);
    }

    public async Task<Notifications> GetNotificationByIdAsync(int notificationId)
    {
        var filter = Builders<Notifications>.Filter.Eq(n => n.Id, notificationId);
        var notification = await _notifications.Find(filter).FirstOrDefaultAsync();
        return notification;
    }
}
