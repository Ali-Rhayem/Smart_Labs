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
    public class RoomController : ControllerBase
    {

        private readonly IRoomService _roomService;

        public RoomController(IRoomService roomService)
        {
            _roomService = roomService;
        }

        // GET: api/Room
        [HttpGet]
        [Authorize]
        public async Task<ActionResult<List<Rooms>>> GetAllRooms()
        {
            return await _roomService.GetAllRoomsAsync();
        }

        // POST: api/Room
        [HttpPost]
        [Authorize]
        public async Task<ActionResult<Rooms>> CreateRoom(Rooms room)
        {
            var existingRoom = await _roomService.GetRoomAsync(room.Name);
            if (existingRoom != null)
            {
                return Conflict();
            }
            return await _roomService.CreateRoomAsync(room);
        }


        // PUT: api/Room/5
        [HttpPut("{name}")]
        [Authorize]
        public async Task<ActionResult<Rooms>> UpdateRoom(string name, Rooms room)
        {
            var existingRoom = await _roomService.GetRoomAsync(name);
            if (existingRoom == null)
            {
                return NotFound();
            }
            return await _roomService.UpdateRoomAsync(name, room);
        }


        // DELETE: api/Room/5
        [HttpDelete("{name}")]
        [Authorize]
        public async Task<ActionResult> DeleteRoom(string name)
        {
            var existingRoom = await _roomService.GetRoomAsync(name);
            if (existingRoom == null)
            {
                return NotFound();
            }
            var result = await _roomService.DeleteRoomAsync(name);
            if (result)
            {
                return Ok();
            }
            return StatusCode(StatusCodes.Status500InternalServerError);
        }

    }
}
