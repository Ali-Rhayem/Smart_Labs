using Microsoft.AspNetCore.Http;
using Microsoft.AspNetCore.Mvc;
using System.Security.Claims;
using Microsoft.AspNetCore.Authorization;
using backend.Models;
using backend.Services;
using System.ComponentModel.DataAnnotations;

namespace backend.Controllers
{
    [Route("api/[controller]")]
    [ApiController]
    public class LabController : ControllerBase
    {
        private readonly LabService _labService;
        private readonly UserService _userService;

        public LabController(LabService labService, UserService userService)
        {
            _labService = labService;
            _userService = userService;
        }


        // GET: api/lab
        [HttpGet]
        [Authorize(Roles = "admin")]
        public async Task<ActionResult<List<Lab>>> GetAllLabs()
        {
            var labs = await _labService.GetAllLabsAsync();
            return Ok(labs);
        }

        // GET: api/lab/instructor/{instructorId}
        [HttpGet("instructor/{instructorId}")]
        [Authorize(Roles = "instructor,admin")]
        public async Task<ActionResult<List<Lab>>> GetInstructorLabs(int instructorId)
        {
            var userIdClaim = HttpContext.User.FindFirst(ClaimTypes.NameIdentifier);
            var userRoleClaim = HttpContext.User.FindFirst(ClaimTypes.Role);
            // check if instructor is the same as the logged in user
            if (userIdClaim == null || (userIdClaim.Value != instructorId.ToString() && userRoleClaim!.Value != "admin"))
            {
                return Unauthorized();
            }
            var user = await _userService.GetUserById(instructorId);
            if (user == null || user.Role != "instructor")
            {
                return BadRequest(new { errors = "User is not an instructor." });
            }
            var labs = await _labService.GetInstructorLabsAsync(instructorId);
            return Ok(labs);
        }

        // GET: api/lab/student/{studentId}
        [HttpGet("student/{studentId}")]
        [Authorize(Roles = "student, admin")]
        public async Task<ActionResult<List<Lab>>> GetStudentLabs(int studentId)
        {
            var userIdClaim = HttpContext.User.FindFirst(ClaimTypes.NameIdentifier);
            var userRoleClaim = HttpContext.User.FindFirst(ClaimTypes.Role);
            // check if student is the same as the logged in user
            if (userIdClaim == null || (userIdClaim.Value != studentId.ToString() && userRoleClaim!.Value != "admin"))
            {
                return Unauthorized();
            }
            var user = await _userService.GetUserById(studentId);
            if (user == null || user.Role != "student")
            {
                return BadRequest(new { errors = "User is not a student." });
            }
            var labs = await _labService.GetStudentLabsAsync(studentId);
            return Ok(labs);
        }

        // GET: api/lab/{labId}/students
        [HttpGet("{labId}/students")]
        [Authorize]
        public async Task<ActionResult<List<User>>> GetStudentsInLab(int labId)
        {
            var students = await _labService.GetStudentsInLabAsync(labId);
            if (students == null)
            {
                return NotFound();
            }
            return Ok(students);
        }

        // GET: api/lab/{labId}/instructors
        [HttpGet("{labId}/instructors")]
        [Authorize]
        public async Task<ActionResult<List<User>>> GetInstructorsInLab(int labId)
        {
            var instructors = await _labService.GetInstructorsInLabAsync(labId);
            if (instructors == null)
            {
                return NotFound();
            }
            return Ok(instructors);
        }

        // GET: api/lab/{id}
        [HttpGet("{id}")]
        [Authorize]
        public async Task<ActionResult<Lab>> GetLabById(int id)
        {
            var lab = await _labService.GetLabByIdAsync(id);

            if (lab == null)
                return NotFound();

            return Ok(lab);
        }

        // POST: api/lab
        [HttpPost]
        [Authorize(Roles = "admin,instructor")]
        public async Task<ActionResult<Lab>> CreateLab(CreateLab createLab)
        {
            var user_id = HttpContext.User.FindFirst(ClaimTypes.NameIdentifier);
            var user_role = HttpContext.User.FindFirst(ClaimTypes.Role);
            if (user_role!.Value == "instructor")
            {
                createLab.Lab.Instructors.Add(int.Parse(user_id!.Value));
            }
            else if (createLab.Lab.Instructors.Count == 0)
            {
                return BadRequest(new { errors = "Lab must have at least one instructor." });
            }
            var lab = createLab.Lab;
            var emails = createLab.Emails;
            foreach (var email in emails)
                if (!new EmailAddressAttribute().IsValid(email))
                    emails.Remove(email);

            var createdLab = await _labService.CreateLabAsync(lab, emails);
            return CreatedAtAction(nameof(GetLabById), new { id = createdLab.Id }, createdLab);
        }

        // PUT: api/lab/{id}
        [HttpPut("{id}")]
        [Authorize(Roles = "admin,instructor")]
        public async Task<ActionResult> UpdateLab(int id, Lab updatedFields)
        {
            var userRoleClaim = HttpContext.User.FindFirst(ClaimTypes.Role);
            var userIdClaim = HttpContext.User.FindFirst(ClaimTypes.NameIdentifier);

            if (userRoleClaim!.Value == "instructor")
            {
                var lab = await _labService.GetLabByIdAsync(id);
                if (lab == null || !lab.Instructors.Contains(int.Parse(userIdClaim!.Value)))
                {
                    return Unauthorized();
                }
            }

            var result = await _labService.UpdateLabAsync(id, updatedFields);

            if (!result)
                return NotFound();

            return NoContent();
        }

        // DELETE: api/lab/{id}
        [HttpDelete("{id}")]
        [Authorize(Roles = "admin,instructor")]
        public async Task<ActionResult> DeleteLab(int id)
        {
            var userRoleClaim = HttpContext.User.FindFirst(ClaimTypes.Role);
            var userIdClaim = HttpContext.User.FindFirst(ClaimTypes.NameIdentifier);

            if (userRoleClaim!.Value == "instructor")
            {
                var lab = await _labService.GetLabByIdAsync(id);
                if (lab == null || !lab.Instructors.Contains(int.Parse(userIdClaim!.Value)))
                {
                    return Unauthorized();
                }
            }

            var result = await _labService.DeleteLabAsync(id);

            if (!result)
                return NotFound();

            return NoContent();
        }

        // POST: api/lab/{labId}/students
        [HttpPost("{labId}/students")]
        [Authorize(Roles = "admin,instructor")]
        public async Task<ActionResult> AddStudentToLab(int labId, List<String> emails)
        {
            foreach (var email in emails)
                if (!new EmailAddressAttribute().IsValid(email))
                    emails.Remove(email);

            var userRoleClaim = HttpContext.User.FindFirst(ClaimTypes.Role);
            var userIdClaim = HttpContext.User.FindFirst(ClaimTypes.NameIdentifier);
            var lab = await _labService.GetLabByIdAsync(labId);
            if (lab == null)
            {
                return NotFound();
            }
            if (userRoleClaim!.Value == "instructor")
            {
                if (lab == null || !lab.Instructors.Contains(int.Parse(userIdClaim!.Value)))
                {
                    return Unauthorized();
                }
            }

            foreach (var student_email in emails)
            {
                var student = await _userService.GetUserByEmailAsync(student_email);
                if (student == null)
                    continue;
                if (lab.Students.Contains(student.Id) || student.Role != "student")
                    emails.Remove(student_email);
            }
            if (emails.Count == 0)
            {
                return BadRequest(new { errors = "No valid students to add." });
            }

            var result = await _labService.AddStudentToLabAsync(labId, emails);

            if (!result)
                return NotFound();

            return NoContent();
        }

        // DELETE: api/lab/{labId}/students/{studentId}
        [HttpDelete("{labId}/students/{studentId}")]
        [Authorize(Roles = "admin,instructor")]
        public async Task<ActionResult> RemoveStudentFromLab(int labId, int studentId)
        {
            var userRoleClaim = HttpContext.User.FindFirst(ClaimTypes.Role);
            var userIdClaim = HttpContext.User.FindFirst(ClaimTypes.NameIdentifier);

            if (userRoleClaim!.Value == "instructor")
            {
                var lab = await _labService.GetLabByIdAsync(labId);
                if (lab == null)
                    return NotFound();
                if (!lab.Instructors.Contains(int.Parse(userIdClaim!.Value)))
                {
                    return Unauthorized();
                }
            }

            var result = await _labService.RemoveStudentFromLabAsync(labId, studentId);

            if (!result)
                return NotFound();

            return NoContent();
        }

        // POST: api/lab/{labId}/instructors/{instructorId}
        [HttpPost("{labId}/instructors/{instructorId}")]
        [Authorize(Roles = "admin,instructor")]
        public async Task<ActionResult> AddInstructorToLab(int labId, int instructorId)
        {
            var userRoleClaim = HttpContext.User.FindFirst(ClaimTypes.Role);
            var userIdClaim = HttpContext.User.FindFirst(ClaimTypes.NameIdentifier);
            var lab = await _labService.GetLabByIdAsync(labId);

            if (lab == null)
                return NotFound();

            if (userRoleClaim!.Value == "instructor")
            {
                if (!lab.Instructors.Contains(int.Parse(userIdClaim!.Value)))
                {
                    return Unauthorized();
                }
            }
            // check if instructorid is realy an instructor
            var instructor = await _userService.GetUserById(instructorId);
            if (instructor == null || instructor.Role != "instructor")
                return BadRequest(new { errors = "User is not an instructor." });

            // check if instructor in lab
            if (lab.Instructors.Contains(instructorId))
            {
                return BadRequest(new { errors = "Instructor already in lab." });
            }
            var result = await _labService.AddInstructorToLabAsync(labId, instructorId);

            if (!result)
                return NotFound();

            return NoContent();
        }

        // DELETE: api/lab/{labId}/instructors/{instructorId}
        [HttpDelete("{labId}/instructors/{instructorId}")]
        [Authorize(Roles = "admin,instructor")]
        public async Task<ActionResult> RemoveInstructorFromLab(int labId, int instructorId)
        {
            var userRoleClaim = HttpContext.User.FindFirst(ClaimTypes.Role);
            var userIdClaim = HttpContext.User.FindFirst(ClaimTypes.NameIdentifier);
            var lab = await _labService.GetLabByIdAsync(labId);

            if (lab == null)
                return NotFound();

            if (userRoleClaim!.Value == "instructor")
            {
                if (!lab.Instructors.Contains(int.Parse(userIdClaim!.Value)))
                {
                    return Unauthorized();
                }
            }

            var result = await _labService.RemoveInstructorFromLabAsync(labId, instructorId);

            if (!result)
                return NotFound();

            return NoContent();
        }

        // POST: api/lab/{labId}/ppe
        [HttpPost("{labId}/ppe")]
        [Authorize(Roles = "admin,instructor")]
        public async Task<ActionResult> EditPPEOfLab(int labId, List<int> ppeId)
        {
            var userRoleClaim = HttpContext.User.FindFirst(ClaimTypes.Role);
            var userIdClaim = HttpContext.User.FindFirst(ClaimTypes.NameIdentifier);
            var lab = await _labService.GetLabByIdAsync(labId);

            if (lab == null)
                return NotFound();


            if (userRoleClaim!.Value == "instructor")
            {
                if (!lab.Instructors.Contains(int.Parse(userIdClaim!.Value)))
                {
                    return Unauthorized();
                }
            }

            var result = await _labService.EditPPEOfLabAsync(labId, ppeId);

            if (!result)
                return NotFound();

            return NoContent();
        }

    }
}
