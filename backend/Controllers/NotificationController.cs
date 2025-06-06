using System.Security.Claims;
using backend.helpers;
using backend.Services;
using FirebaseAdmin.Messaging;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Http;
using Microsoft.AspNetCore.Http.HttpResults;
using Microsoft.AspNetCore.Mvc;

namespace backend.Controllers
{
    [Route("api/[controller]")]
    [ApiController]
    public class NotificationController : ControllerBase
    {

        private readonly INotificationService _notificationService;
        private readonly IJwtTokenHelper _jwtTokenHelper;

        public NotificationController(INotificationService notificationService, IJwtTokenHelper jwtTokenHelper)
        {
            _notificationService = notificationService;
            _jwtTokenHelper = jwtTokenHelper;
        }


        // POST: api/Notification/send
        [HttpPost("send")]
        [Authorize]
        public async Task<ActionResult> SendNotification(NotificationModel notification)
        {
            await _notificationService.SendNotificationAsync(notification);
            return Ok();
        }

        // GET: api/Notification/user/{userId}
        [HttpGet("user/{userId}")]
        [Authorize]
        public async Task<ActionResult> GetNotificationsByUserId(int userId)
        {
            var userIdClaim = HttpContext.User.FindFirst(ClaimTypes.NameIdentifier);
            if (userId != int.Parse(userIdClaim!.Value))
            {
                return Unauthorized();
            }

            var notifications = await _notificationService.GetNotificationsByUserIdAsync(userId);
            return Ok(notifications);
        }

        // PUT: api/Notification/mark-as-read/{notificationId}
        [HttpPut("mark-as-read/{notificationId}")]
        [Authorize]
        public async Task<ActionResult> MarkNotificationAsRead(int notificationId)
        {
            var userIdClaim = HttpContext.User.FindFirst(ClaimTypes.NameIdentifier);
            var notification = await _notificationService.GetNotificationByIdAsync(notificationId);
            if (notification == null || notification.UserID != int.Parse(userIdClaim!.Value))
            {
                return Unauthorized();
            }

            await _notificationService.MarkNotificationAsReadAsync(notificationId);
            return Ok();
        }

        // PUT: api/Notification/mark-as-deleted/{notificationId}
        [HttpPut("mark-as-deleted/{notificationId}")]
        [Authorize]
        public async Task<ActionResult> MarkNotificationAsDeleted(int notificationId)
        {
            var userIdClaim = HttpContext.User.FindFirst(ClaimTypes.NameIdentifier);
            var notification = await _notificationService.GetNotificationByIdAsync(notificationId);
            if (notification == null || notification.UserID != int.Parse(userIdClaim!.Value))
            {
                return Unauthorized();
            }

            await _notificationService.MarkNotificationAsDeletedAsync(notificationId);
            return Ok();
        }

        // PUT: api/Notification/mark-all-as-read
        [HttpPut("mark-all-as-read")]
        [Authorize]
        public async Task<ActionResult> MarkAllNotificationsAsRead()
        {
            var userIdClaim = HttpContext.User.FindFirst(ClaimTypes.NameIdentifier);
            await _notificationService.MarkAllNotificationsAsReadAsync(int.Parse(userIdClaim!.Value));
            return Ok();
        }

        // PUT: api/Notification/mark-all-as-deleted
        [HttpPut("mark-all-as-deleted")]
        [Authorize]
        public async Task<ActionResult> MarkAllNotificationsAsDeleted()
        {
            var userIdClaim = HttpContext.User.FindFirst(ClaimTypes.NameIdentifier);
            await _notificationService.MarkAllNotificationsAsDeletedAsync(int.Parse(userIdClaim!.Value));
            return Ok();
        }
    }
}
