using Gestion.Colegial.Business.Interfaces;
using Gestion.Colegial.Entities;
using Microsoft.AspNetCore.Mvc;

namespace Gestion.Colegial.Api.Controllers
{
    /// <summary>
    /// Endpoints de consulta del directorio de alumnos graduados (app.tbAlumnosGraduados).
    /// </summary>
    [ApiController]
    [Route("api/v1/[controller]")]
    public class GraduadosController : ControllerBase
    {
        private readonly IGraduacionService _service;

        public GraduadosController(IGraduacionService service)
        {
            _service = service;
        }

        [HttpGet]
        [Route("ListAsync")]
        public async Task<IActionResult> List()
        {
            Answer answer = await _service.ListGraduados();
            if (answer.Access) return BadRequest(answer.Message ?? "Error consultando graduados.");
            return Ok(answer.Data);
        }

        [HttpGet]
        [Route("FindAsync")]
        public async Task<IActionResult> Find([FromQuery] int id)
        {
            if (id <= 0) return BadRequest("id requerido.");
            Answer answer = await _service.FindGraduado(id);
            if (answer.Access) return NotFound(answer.Message ?? "No se encontro el graduado solicitado.");
            return Ok(answer.Data);
        }
    }
}
