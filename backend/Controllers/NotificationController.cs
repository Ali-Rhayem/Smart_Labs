using System.Security.Claims;
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

        private readonly NotificationService _notificationService;
        private readonly JwtTokenHelper _jwtTokenHelper;

        public NotificationController(NotificationService notificationService, JwtTokenHelper jwtTokenHelper)
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
    }
}
