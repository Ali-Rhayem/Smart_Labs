using Microsoft.AspNetCore.Http;
using Microsoft.AspNetCore.Mvc;
using System.Security.Claims;
using Microsoft.AspNetCore.Authorization;
using backend.Models;
using backend.Services;
using System.ComponentModel.DataAnnotations;
using FirebaseAdmin.Auth;
using System.Text.Json;

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
            else if (createLab.Lab.Instructors.Count == 0 && createLab.Instructor_Emails.Count == 0)
            {
                return BadRequest(new { errors = "Lab must have at least one instructor." });
            }
            var lab = createLab.Lab;
            var students_emails = createLab.Student_Emails;
            foreach (var email in students_emails)
                if (!new EmailAddressAttribute().IsValid(email))
                    students_emails.Remove(email);

            var instructers_emails = createLab.Instructor_Emails;
            foreach (var email in instructers_emails)
                if (!new EmailAddressAttribute().IsValid(email))
                    instructers_emails.Remove(email);

            var createdLab = await _labService.CreateLabAsync(lab, students_emails, instructers_emails);

            return createdLab.Match<ActionResult>(
                lab => CreatedAtAction(nameof(GetLabById), new { id = lab.Id }, lab),
                error => StatusCode(error.StatusCode, new { errors = error.Message })
                );
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

            if (result.Count == 0)
                return NotFound(new { errors = "No students added." });

            return Ok(result);
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

        // POST: api/lab/{labId}/instructors
        [HttpPost("{labId}/instructors")]
        [Authorize(Roles = "admin,instructor")]
        public async Task<ActionResult> AddInstructorToLab(int labId, [FromBody] List<string> emails)
        {
            var userRoleClaim = HttpContext.User.FindFirst(ClaimTypes.Role);
            var userIdClaim = HttpContext.User.FindFirst(ClaimTypes.NameIdentifier);
            var lab = await _labService.GetLabByIdAsync(labId);

            if (lab == null)
                return NotFound(new { errors = "Lab not found." });

            if (userRoleClaim!.Value == "instructor")
            {
                if (!lab.Instructors.Contains(int.Parse(userIdClaim!.Value)))
                {
                    return Unauthorized();
                }
            }
            // check if emails is valid
            foreach (var email in emails)
            {
                var instructor = await _userService.GetUserByEmailAsync(email);
                if (!new EmailAddressAttribute().IsValid(email))
                    emails.Remove(email);
                else if (instructor == null || instructor.Role != "instructor")
                    emails.Remove(email);
                else if (lab.Instructors.Contains(instructor.Id))
                    emails.Remove(email);

            }
            if (emails.Count == 0)
                return BadRequest(new { errors = "No valid instructors to add." });

            int[] instructorIds = new int[emails.Count];
            foreach (var email in emails)
            {
                var instructor = await _userService.GetUserByEmailAsync(email);
                instructorIds.Append(instructor.Id);
            }
            var result = await _labService.AddInstructorToLabAsync(labId, instructorIds);

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
                return NotFound(new { errors = "Instructor not found in lab." });

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
                return NotFound(new { errors = "Lab not found." });


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

        // POST: api/lab/{labId}/endlab
        [HttpPost("{labId}/endlab")]
        [Authorize(Roles = "admin,instructor")]
        public async Task<ActionResult> EndLab(int labId)
        {
            var userRoleClaim = HttpContext.User.FindFirst(ClaimTypes.Role);
            var userIdClaim = HttpContext.User.FindFirst(ClaimTypes.NameIdentifier);
            var lab = await _labService.GetLabByIdAsync(labId);

            if (lab == null)
                return NotFound(new { errors = "Lab not found." });

            if (userRoleClaim!.Value == "instructor")
            {
                if (!lab.Instructors.Contains(int.Parse(userIdClaim!.Value)))
                {
                    return Unauthorized();
                }
            }

            var result = await _labService.EndLabAsync(labId);

            if (!result)
                return NotFound();

            return NoContent();
        }

        // POST: api/lab/{labId}/announcement
        [HttpPost("{labId}/announcement")]
        [Authorize(Roles = "instructor")]
        public async Task<ActionResult> SendAnnouncementToLab(int labId, Announcement announcement)
        {
            var userIdClaim = HttpContext.User.FindFirst(ClaimTypes.NameIdentifier);
            var lab = await _labService.GetLabByIdAsync(labId);

            if (lab == null)
                return NotFound(new { errors = "Lab not found." });

            if (!lab.Instructors.Contains(int.Parse(userIdClaim!.Value)))
            {
                return Unauthorized();
            }

            announcement.Sender = int.Parse(userIdClaim!.Value);

            var result = await _labService.SendAnnouncementToLabAsync(labId, announcement);

            if (!result)
                return NotFound();

            return NoContent();
        }

        // DELETE: api/lab/{labId}/announcement/{announcementId}
        [HttpDelete("{labId}/announcement/{announcementId}")]
        [Authorize(Roles = "instructor")]
        public async Task<ActionResult> DeleteAnnouncement(int labId, int announcementId)
        {
            var userIdClaim = HttpContext.User.FindFirst(ClaimTypes.NameIdentifier);
            var lab = await _labService.GetLabByIdAsync(labId);

            if (lab == null)
                return NotFound(new { errors = "Lab not found." });

            if (!lab.Instructors.Contains(int.Parse(userIdClaim!.Value)))
            {
                return Unauthorized();
            }

            var result = await _labService.DeleteAnnouncementFromLabAsync(labId, announcementId);

            if (!result)
                return NotFound();

            return NoContent();
        }

        // POST: api/lab/{labId}/announcement/{announcementId}/comment
        [HttpPost("{labId}/announcement/{announcementId}/comment")]
        [Authorize(Roles = "instructor,student")]
        public async Task<ActionResult> CommentOnAnnouncement(int labId, int announcementId, Comment comment)
        {
            var userIdClaim = HttpContext.User.FindFirst(ClaimTypes.NameIdentifier);
            var userRoleClaim = HttpContext.User.FindFirst(ClaimTypes.Role);
            var lab = await _labService.GetLabByIdAsync(labId);

            if (lab == null)
                return NotFound(new { errors = "Lab not found." });

            if (userRoleClaim!.Value == "instructor")
            {
                if (!lab.Instructors.Contains(int.Parse(userIdClaim!.Value)))
                {
                    return Unauthorized();
                }
            }
            else if (userRoleClaim!.Value == "student")
            {
                if (!lab.Students.Contains(int.Parse(userIdClaim!.Value)))
                {
                    return Unauthorized();
                }
            }

            comment.Sender = int.Parse(userIdClaim!.Value);

            var result = await _labService.CommentOnAnnouncementAsync(labId, announcementId, comment);

            if (!result)
                return NotFound();

            return NoContent();
        }

        // DELETE: api/lab/{labId}/announcement/{announcementId}/comment/{commentId}
        [HttpDelete("{labId}/announcement/{announcementId}/comment/{commentId}")]
        [Authorize(Roles = "instructor,student")]
        public async Task<ActionResult> DeleteComment(int labId, int announcementId, int commentId)
        {
            var userIdClaim = HttpContext.User.FindFirst(ClaimTypes.NameIdentifier);
            var userRoleClaim = HttpContext.User.FindFirst(ClaimTypes.Role);
            var lab = await _labService.GetLabByIdAsync(labId);

            if (lab == null)
                return NotFound(new { errors = "Lab not found." });

            if (userRoleClaim!.Value == "instructor")
            {
                if (!lab.Instructors.Contains(int.Parse(userIdClaim!.Value)))
                {
                    return Unauthorized();
                }
            }
            else if (userRoleClaim!.Value == "student")
            {
                var comment = await _labService.GetCommentByIdAsync(labId, announcementId, commentId);
                if (comment == null || comment.Sender != int.Parse(userIdClaim!.Value))
                {
                    return Unauthorized();
                }
            }

            var result = await _labService.DeleteCommentFromAnnouncementAsync(labId, announcementId, commentId);

            if (!result)
                return NotFound();

            return NoContent();
        }

        // GET: api/lab/{labId}/announcements
        [HttpGet("{labId}/announcements")]
        [Authorize]
        public async Task<ActionResult<List<AnnouncementDTO>>> GetAnnouncements(int labId)
        {
            var UserIdClaim = HttpContext.User.FindFirst(ClaimTypes.NameIdentifier);
            var lab = await _labService.GetLabByIdAsync(labId);
            if (lab == null)
            {
                return NotFound(new { errors = "Lab not found." });
            }
            if (!lab.Instructors.Contains(int.Parse(UserIdClaim!.Value)) && !lab.Students.Contains(int.Parse(UserIdClaim!.Value)))
            {
                return Unauthorized(new { errors = "User not in lab." });
            }

            var announcements = await _labService.GetAnnouncementsAsync(labId);
            if (announcements == null)
            {
                return NotFound(new { errors = "No Announcements" });
            }
            return Ok(announcements);
        }

        // POST: api/lab/5/startSession
        [HttpPost("{id}/startSession")]
        [Authorize(Roles = "instructor")]
        public async Task<ActionResult> StartSession(int id)
        {
            var userIdClaim = HttpContext.User.FindFirst(ClaimTypes.NameIdentifier);
            var lab = await _labService.GetLabByIdAsync(id);

            if (lab == null)
                return NotFound(new { errors = "Lab not found." });

            if (!lab.Instructors.Contains(int.Parse(userIdClaim!.Value)))
            {
                return Unauthorized();
            }

            var result = await _labService.StartSessionAsync(id);

            return result.Match<ActionResult>(
                _ => NoContent(),
                error => StatusCode(error.StatusCode, new { errors = error.Message })
                );
        }

        // POST: api/lab/5/endSession
        [HttpPost("{id}/endSession")]
        [Authorize(Roles = "instructor")]
        public async Task<ActionResult> EndSession(int id)
        {
            var userIdClaim = HttpContext.User.FindFirst(ClaimTypes.NameIdentifier);
            var lab = await _labService.GetLabByIdAsync(id);

            if (lab == null)
                return NotFound(new { errors = "Lab not found." });

            if (!lab.Instructors.Contains(int.Parse(userIdClaim!.Value)))
            {
                return Unauthorized();
            }

            var result = await _labService.EndSessionAsync(id);

            return result.Match<ActionResult>(
                _ => NoContent(),
                error => StatusCode(error.StatusCode, new { errors = error.Message })
                );
        }

        // GET: api/lab/5/analyze
        [HttpGet("{id}/analyze")]
        [Authorize(Roles = "instructor, admin")]
        public async Task<ActionResult> AnalyzeLab(int id)
        {
            var userIdClaim = HttpContext.User.FindFirst(ClaimTypes.NameIdentifier);
            var userRoleClaim = HttpContext.User.FindFirst(ClaimTypes.Role);
            var lab = await _labService.GetLabByIdAsync(id);

            if (lab == null)
                return NotFound(new { errors = "Lab not found." });

            if (userRoleClaim!.Value == "instructor" && !lab.Instructors.Contains(int.Parse(userIdClaim!.Value)))
                return Unauthorized(new { errors = "User not authorized." });

            var result = await _labService.AnalyzeLabAsync(id);

            return Ok(result);
        }
    }
}
