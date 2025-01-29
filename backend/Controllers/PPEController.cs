using backend.Services;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Http;
using Microsoft.AspNetCore.Http.HttpResults;
using Microsoft.AspNetCore.Mvc;

namespace backend.Controllers
{
    [Route("api/[controller]")]
    [ApiController]
    public class PPEController : ControllerBase
    {
        private readonly PPEService _ppeService;

        public PPEController(PPEService ppeService)
        {
            _ppeService = ppeService;
        }

        // GET: api/PPE
        [HttpGet]
        [Authorize(Roles = "admin,instructor")]
        public async Task<ActionResult<List<PPE>>> GetAllPPE()
        {
            return await _ppeService.GetAllPPEAsync();
        }


    }
}
