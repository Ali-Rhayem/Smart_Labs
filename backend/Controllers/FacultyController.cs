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

        public FacultyController(FacultyService facultyService)
        {
            _facultyService = facultyService;
        }


        [HttpGet]
        [Authorize]
        public async Task<ActionResult<List<Faculty>>> GetAllFaculties()
        {
            return await _facultyService.GetAllFacultiesAsync();
        }

        [HttpPost]
        [Authorize(Roles = "admin")]
        public async Task<ActionResult<Faculty>> AddFaculty(Faculty faculty)
        {
            await _facultyService.AddFacultyAsync(faculty);
            return CreatedAtAction("AddFaculty", new { id = faculty.Id }, faculty);

        }

        [HttpPut("{id}")]
        [Authorize(Roles = "admin")]
        public async Task<ActionResult<Faculty>> UpdateFaculty(int id, Faculty faculty)
        {
            var updatedFaculty = await _facultyService.UpdateFacultNameyAsync(id, faculty);
            if (updatedFaculty == null)
            {
                return NotFound();
            }
            return Ok(updatedFaculty);
        }

        [HttpPost("{id}/major")]
        [Authorize(Roles = "admin")]
        public async Task<ActionResult<Faculty>> AddMajor(int id, string major)
        {
            var updatedFaculty = await _facultyService.AddMajorAsync(id, major);
            if (updatedFaculty == null)
            {
                return NotFound();
            }
            return Ok(updatedFaculty);
        }

        [HttpDelete("{id}/major")]
        [Authorize(Roles = "admin")]
        public async Task<ActionResult<Faculty>> RemoveMajor(int id, string major)
        {
            var updatedFaculty = await _facultyService.RemoveMajorAsync(id, major);
            if (updatedFaculty == null)
            {
                return NotFound();
            }
            return Ok(updatedFaculty);
        }

    }
}
