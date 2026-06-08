using Gestion.Colegial.Business.Interfaces;
using Gestion.Colegial.Entities;
using Microsoft.AspNetCore.Mvc;
using System.Threading.Tasks;

namespace Gestion.Colegial.Api.Controllers
{
    [ApiController]
    [Route("api/v1/[controller]")]
    public class AlumnosDirectorioController : ControllerBase
    {
        private readonly IAlumnosDirectorioService _service;
        public AlumnosDirectorioController(IAlumnosDirectorioService service) { _service = service; }

        [HttpGet("ListAsync")]
        public async Task<IActionResult> List(int? Cur_Id, int? Sec_Id)
        {
            Answer answer = await _service.List(Cur_Id, Sec_Id);
            return Ok(answer.Data);
        }
    }
}
