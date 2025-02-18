using backend.Services;
using Microsoft.AspNetCore.Authorization;
using System.Security.Claims;
using Microsoft.AspNetCore.Http;
using Microsoft.AspNetCore.Http.HttpResults;
using Microsoft.AspNetCore.Mvc;

namespace backend.Controllers
{
    [Route("api/[controller]")]
    [ApiController]
    public class DashboardController : ControllerBase
    {
        private readonly DashboardService _dashboardService;

        public DashboardController(DashboardService DashboardService)
        {
            _dashboardService = DashboardService;
        }

        [HttpGet]
        [Authorize]
        public async Task<ActionResult> GetDashboardAsync()
        {
            var userIdClaim = HttpContext.User.FindFirst(ClaimTypes.NameIdentifier);
            var userRoleClaim = HttpContext.User.FindFirst(ClaimTypes.Role);

            if (userIdClaim == null || userRoleClaim == null)
                return Unauthorized(new { errors = "Invalid token" });

            int userId = int.Parse(userIdClaim.Value);
            var result = new Dictionary<string, object>();

            result = await _dashboardService.GetDashboardAsync(userId, userRoleClaim.Value);

            if (result == null)
            {
                return NotFound(new { errors = "Dashboard not found" });
            }

            return Ok(result);

        }


    }
}
