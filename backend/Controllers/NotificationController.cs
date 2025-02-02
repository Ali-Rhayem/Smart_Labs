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
    }
}
