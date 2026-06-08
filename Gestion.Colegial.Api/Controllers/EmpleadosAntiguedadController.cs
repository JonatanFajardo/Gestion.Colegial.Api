using Gestion.Colegial.Business.Interfaces;
using Gestion.Colegial.Entities;
using Microsoft.AspNetCore.Mvc;
using System.Threading.Tasks;

namespace Gestion.Colegial.Api.Controllers
{
    [ApiController]
    [Route("api/v1/[controller]")]
    public class EmpleadosAntiguedadController : ControllerBase
    {
        private readonly IEmpleadosAntiguedadService _service;
        public EmpleadosAntiguedadController(IEmpleadosAntiguedadService service) { _service = service; }

        [HttpGet("ListAsync")]
        public async Task<IActionResult> List()
        {
            Answer answer = await _service.List();
            return Ok(answer.Data);
        }
    }
}
