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
    public class SessionsController : ControllerBase
    {

        private readonly ISessionService _sessionService;

        public SessionsController(ISessionService sessionService)
        {
            _sessionService = sessionService;
        }

        // GET: api/Sessions/lab/5
        [HttpGet("lab/{id}")]
        [Authorize]
        public async Task<ActionResult<List<SessionsDTO>>> GetSessionsOfLab(int id)
        {
            return await _sessionService.GetSessionsOfLabAsync(id);
        }

    }
}
