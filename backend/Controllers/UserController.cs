using Microsoft.AspNetCore.Http;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using backend.Models;
using backend.Services;

namespace backend.Controllers

{
    [Route("api/[controller]")]
    [ApiController]
    public class UserController : ControllerBase
    {
        private readonly UserService _userService;
        private readonly JwtTokenHelper _jwtTokenHelper;

        // Inject UserService into the controller
        public UserController(UserService userService, JwtTokenHelper jwtTokenHelper)
        {
            _userService = userService;
            _jwtTokenHelper = jwtTokenHelper;
        }

        // for testing purposes
        // GET: api/user
        [HttpGet]
        [Authorize(Roles = "admin")]
        public async Task<ActionResult<List<User>>> GetAllUsers()
        {
            var users = await _userService.GetAllUsers();
            return Ok(users);
        }

        // GET: api/user/{id}
        [HttpGet("{id}")]
        [Authorize]
        public async Task<ActionResult<User>> GetUserById(int id)
        {
            var user = await _userService.GetUserById(id);

            if (user == null)
                return NotFound();

            return Ok(user);
        }

        // for testing purposes
        // POST: api/user
        [HttpPost]
        [Authorize(Roles = "admin")]
        public async Task<ActionResult<User>> CreateUser(User user)
        {
            // Validate input
            if (string.IsNullOrEmpty(user.Password))
            {
                return BadRequest("Password is required.");
            }
            user.Password = BCrypt.Net.BCrypt.HashPassword(user.Password);

            var createdUser = await _userService.CreateUser(user);
            return CreatedAtAction(nameof(GetUserById), new { id = createdUser.Id }, createdUser);
        }

        // PUT: api/user/{id}
        [HttpPut("{id}")]
        [Authorize(Roles = "admin,student")]
        public async Task<ActionResult> UpdateUser(int id, User updatedFields)
        {
            var result = await _userService.UpdateUser(id, updatedFields);

            if (!result)
                return BadRequest("Update failed.");

            return NoContent(); // 204 No Content
        }

        // DELETE: api/user/{id}
        [HttpDelete("{id}")]
        [Authorize(Roles = "admin")]
        public async Task<ActionResult> DeleteUser(int id)
        {
            var result = await _userService.DeleteUser(id);

            if (!result)
                return NotFound();

            return NoContent(); // 204 No Content
        }

        [HttpPost("login")]
        [AllowAnonymous]
        public async Task<IActionResult> Login([FromBody] LoginRequest loginRequest)
        {
            // Validate the request
            if (loginRequest == null || string.IsNullOrEmpty(loginRequest.Email) || string.IsNullOrEmpty(loginRequest.Password))
            {
                return BadRequest("Email and password are required.");
            }

            // Check the user in the database
            var user = await _userService.GetUserByEmailAsync(loginRequest.Email);

            if (user == null || !BCrypt.Net.BCrypt.Verify(loginRequest.Password, user.Password))
            {
                return Unauthorized("Invalid email or password.");
            }

            // Generate a JWT token
            var token = _jwtTokenHelper.GenerateToken(user.Id, user.Role);

            return Ok(new
            {
                Token = token,
                UserId = user.Id,
                Role = user.Role
            });
        }


    }
}
