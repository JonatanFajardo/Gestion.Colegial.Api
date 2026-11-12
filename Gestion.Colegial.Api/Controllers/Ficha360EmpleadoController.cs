using Gestion.Colegial.Business.Interfaces;
using Gestion.Colegial.Entities;
using Microsoft.AspNetCore.Mvc;
using System.Threading.Tasks;

namespace Gestion.Colegial.Api.Controllers
{
    [ApiController]
    [Route("api/v1/[controller]")]
    public class Ficha360EmpleadoController : ControllerBase
    {
        private readonly IFicha360EmpleadoService _service;
        public Ficha360EmpleadoController(IFicha360EmpleadoService service) { _service = service; }

        [HttpGet("ResumenAsync")]
        public async Task<IActionResult> Resumen(int Emp_Id)
        {
            Answer answer = await _service.Resumen(Emp_Id);
            return Ok(answer.Data);
        }
    }
}
