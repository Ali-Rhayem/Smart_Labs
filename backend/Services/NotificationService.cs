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

    public async Task<Notifications> GetNotificationByIdAsync(int notificationId)
    {
        var filter = Builders<Notifications>.Filter.Eq(n => n.Id, notificationId);
        var notification = await _notifications.Find(filter).FirstOrDefaultAsync();
        return notification;
    }
}
