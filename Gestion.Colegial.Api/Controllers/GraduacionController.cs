using Gestion.Colegial.Business.Interfaces;
using Gestion.Colegial.Entities;
using Microsoft.AspNetCore.Mvc;

namespace Gestion.Colegial.Api.Controllers
{
    /// <summary>
    /// Endpoints del flujo de graduacion: lista de candidatos, ejecucion
    /// de la graduacion individual y backfill historico.
    /// </summary>
    [ApiController]
    [Route("api/v1/[controller]")]
    public class GraduacionController : ControllerBase
    {
        private readonly IGraduacionService _service;

        public GraduacionController(IGraduacionService service)
        {
            _service = service;
        }

        /// <summary>
        /// Obtiene la lista de candidatos a graduacion desde app.vCandidatosGraduacion.
        /// </summary>
        [HttpGet]
        [Route("CandidatosAsync")]
        public async Task<IActionResult> Candidatos()
        {
            Answer answer = await _service.ListCandidatos();
            if (answer.Access) return BadRequest(answer.Message ?? "Error consultando candidatos.");
            return Ok(answer.Data);
        }

        /// <summary>
        /// Ejecuta app.spGraduarAlumno para un alumno especifico.
        /// </summary>
        [HttpPost]
        [Route("GraduarAsync")]
        public async Task<IActionResult> Graduar([FromQuery] int alumnoId, [FromQuery] int usuarioId)
        {
            if (alumnoId <= 0) return BadRequest("alumnoId requerido.");
            if (usuarioId <= 0) return BadRequest("usuarioId requerido.");

            Answer answer = await _service.GraduarAlumno(alumnoId, usuarioId);
            if (answer.Access)
            {
                // RAISERROR del SP — devolvemos 400 con el mensaje original.
                return BadRequest(answer.Message ?? "Error al graduar al alumno.");
            }
            return Ok(new { success = true, message = answer.Message });
        }

        /// <summary>
        /// Ejecuta app.spBackfillGraduadosHistoricos. Por defecto en dry-run.
        /// </summary>
        [HttpPost]
        [Route("BackfillAsync")]
        public async Task<IActionResult> Backfill(
            [FromQuery] int? anio = null,
            [FromQuery] int topN = 50,
            [FromQuery] bool dryRun = true)
        {
            Answer answer = await _service.Backfill(anio, topN, dryRun);
            if (answer.Access) return BadRequest(answer.Message ?? "Error en backfill.");
            return Ok(answer.Data);
        }
    }
}
