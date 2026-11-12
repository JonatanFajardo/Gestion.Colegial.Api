using Gestion.Colegial.Business.Interfaces;
using Gestion.Colegial.Entities;
using Microsoft.AspNetCore.Mvc;
using System.Threading.Tasks;

namespace Gestion.Colegial.Api.Controllers
{
    [ApiController]
    [Route("api/v1/[controller]")]
    public class EmpleadosCumpleanosController : ControllerBase
    {
        private readonly IEmpleadosCumpleanosService _service;
        public EmpleadosCumpleanosController(IEmpleadosCumpleanosService service) { _service = service; }

        [HttpGet("ListAsync")]
        public async Task<IActionResult> List(int? Mes)
        {
            Answer answer = await _service.List(Mes);
            return Ok(answer.Data);
        }
    }
}
