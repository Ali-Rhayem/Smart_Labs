using backend.Services;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Http;
using Microsoft.AspNetCore.Http.HttpResults;
using Microsoft.AspNetCore.Mvc;

namespace backend.Controllers
{
    [Route("api/[controller]")]
    [ApiController]
    public class FacultyController : ControllerBase
    {
        private readonly FacultyService _facultyService;

        public FacultyController( FacultyService facultyService)
        {
            _facultyService = facultyService;
        }

        
        [HttpGet]
        [Authorize]
        public async Task<ActionResult<List<Faculty>>> GetAllFaculties()
        {
            return await _facultyService.GetAllFacultiesAsync();
        }


    }
}
