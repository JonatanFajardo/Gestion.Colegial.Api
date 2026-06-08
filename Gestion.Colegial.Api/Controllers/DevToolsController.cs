using Gestion.Colegial.Business.Interfaces;
using Gestion.Colegial.Entities;
using Microsoft.AspNetCore.Mvc;
using System.Threading.Tasks;

namespace Gestion.Colegial.Api.Controllers
{
    [ApiController]
    [Route("api/v1/[controller]")]
    public class DevToolsController : ControllerBase
    {
        private readonly IDevToolsService _service;
        public DevToolsController(IDevToolsService service) { _service = service; }

        [HttpGet("DetectarAsync")]
        public async Task<IActionResult> Detectar(int? AnioObjetivo = null)
        {
            Answer a = await _service.Detectar(AnioObjetivo);
            return Ok(a.Data);
        }

        [HttpPost("PasoAsync")]
        public async Task<IActionResult> Paso(string Tabla, int Delta)
        {
            Answer a = await _service.Paso(Tabla, Delta);
            return Ok(a.Data);
        }

        [HttpGet("EstadoBDAsync")]
        public async Task<IActionResult> EstadoBD()
        {
            Answer a = await _service.EstadoBD();
            return Ok(a.Data);
        }

        [HttpGet("RolesAsync")]
        public async Task<IActionResult> Roles()
        {
            Answer a = await _service.ListarRoles();
            return Ok(a.Data);
        }
    }
}
