using Gestion.Colegial.Business.Interfaces;
using Gestion.Colegial.Entities;
using Microsoft.AspNetCore.Mvc;
using System.Threading.Tasks;

namespace Gestion.Colegial.Api.Controllers
{
    [ApiController]
    [Route("api/v1/[controller]")]
    public class MisAlumnosController : ControllerBase
    {
        private readonly IMisAlumnosService _service;
        public MisAlumnosController(IMisAlumnosService service) { _service = service; }

        [HttpGet("ListAsync")]
        public async Task<IActionResult> List(int Hor_Id)
        {
            Answer answer = await _service.GetByHorario(Hor_Id);
            return Ok(answer.Data);
        }
    }
}
