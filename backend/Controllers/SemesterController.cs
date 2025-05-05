using backend.helpers;
using backend.Services;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Http;
using Microsoft.AspNetCore.Http.HttpResults;
using Microsoft.AspNetCore.Mvc;

namespace backend.Controllers
{
    [Route("api/[controller]")]
    [ApiController]
    public class SemesterController : ControllerBase
    {
        private readonly IJwtTokenHelper _jwtTokenHelper;
        private readonly ISemesterService _semesterService;

        public SemesterController(IJwtTokenHelper jwtTokenHelper, ISemesterService semesterService)
        {
            _jwtTokenHelper = jwtTokenHelper;
            _semesterService = semesterService;
        }

        // GET: api/Semester
        [HttpGet]
        [Authorize]
        public async Task<ActionResult<List<Semester>>> GetAllSemesters()
        {
            return await _semesterService.GetAllSemestersAsync();
        }

        // GET: api/Semester/5
        [HttpGet("{id}")]
        [Authorize]
        public async Task<ActionResult<Semester>> GetSemesterById(int id)
        {
            var semester = await _semesterService.GetSemesterByIdAsync(id);

            if (semester == null)
            {
                return NotFound();
            }

            return Ok(semester);
        }

        // POST: api/Semester/list
        [HttpGet("/list")]
        [Authorize]
        public async Task<ActionResult<Semester>> GetListOfSemesters([FromBody] List<int> ids)
        {
            List<Semester> semester = await _semesterService.GetListOfSemestersAsync(ids);

            if (semester == null)
            {
                return NotFound();
            }

            return Ok(semester);
        }


        // POST: api/Semester
        [HttpPost]
        [Authorize(Roles = "admin")]
        public async Task<ActionResult<Semester>> CreateSemester(Semester semester)
        {
            var createdSemester = await _semesterService.CreateSemesterAsync(semester);
            return CreatedAtAction(nameof(GetSemesterById), new { id = createdSemester.Id }, createdSemester);
        }

        // PUT: api/Semester/5
        [HttpPut("{id}")]
        [Authorize(Roles = "admin")]
        public async Task<ActionResult<Semester>> UpdateSemester(int id, Semester semester)
        {
            var updated = await _semesterService.UpdateSemesterAsync(id, semester);

            if (updated == null)
            {
                return NotFound();
            }

            return Ok(updated);
        }

        // DELETE: api/Semester/5
        [HttpDelete("{id}")]
        [Authorize(Roles = "admin")]
        public async Task<ActionResult> DeleteSemester(int id)
        {
            var deleted = await _semesterService.DeleteSemesterAsync(id);

            if (!deleted)
            {
                return NotFound();
            }

            return NoContent();
        }

        // PUT: api/Semester/5/current
        [HttpPut("{id}/current")]
        [Authorize(Roles = "admin")]
        public async Task<ActionResult> SetCurrentSemester(int id)
        {
            var result = await _semesterService.SetCurrentSemesterAsync(id);

            if (!result)
            {
                return NotFound();
            }

            return NoContent();
        }


    }
}
