using Gestion.Colegial.Business.Interfaces;
using Gestion.Colegial.Entities;
using Microsoft.AspNetCore.Mvc;
using System.Threading.Tasks;

namespace Gestion.Colegial.Api.Controllers
{
    [ApiController]
    [Route("api/v1/[controller]")]
    public class Ficha360AlumnoController : ControllerBase
    {
        private readonly IFicha360AlumnoService _service;
        public Ficha360AlumnoController(IFicha360AlumnoService service) { _service = service; }

        [HttpGet("ResumenAsync")]
        public async Task<IActionResult> Resumen(int Alu_Id)
        {
            Answer answer = await _service.Resumen(Alu_Id);
            return Ok(answer.Data);
        }
    }
}
