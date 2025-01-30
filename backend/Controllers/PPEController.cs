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
            var ppe = await _ppeService.GetAllPPEAsync();
            return Ok(ppe);
        }

        // GET: api/PPE/list
        [HttpGet("list")]
        [Authorize]
        public async Task<ActionResult<List<PPE>>> GetListOfPPEs([FromBody] List<int> ids)
        {
            var ppe = await _ppeService.GetListOfPPEsAsync(ids);
            return Ok(ppe);
        }

        // POST: api/PPE
        [HttpPost]
        [Authorize(Roles = "admin")]
        public async Task<ActionResult<PPE>> CreatePPE(PPE ppe)
        {
            var createdPPE = await _ppeService.CreatePPEAsync(ppe);
            return CreatedAtAction(nameof(GetAllPPE), new { id = createdPPE.Id }, createdPPE);
        }

        // PUT: api/PPE/5
        [HttpPut("{id}")]
        [Authorize(Roles = "admin")]
        public async Task<ActionResult<PPE>> UpdatePPE(int id, PPE ppe)
        {
            var updatedPPE = await _ppeService.UpdatePPEAsync(id, ppe);
            return Ok(updatedPPE);
        }

        // DELETE: api/PPE/5
        [HttpDelete("{id}")]
        [Authorize(Roles = "admin")]
        public async Task<ActionResult> DeletePPE(int id)
        {
            var result = await _ppeService.DeletePPEAsync(id);
            if (result)
            {
                return NoContent();
            }
            return NotFound();
        }


    }
}
