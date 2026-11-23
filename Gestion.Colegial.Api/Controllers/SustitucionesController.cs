using Gestion.Colegial.Business.Interfaces;
using Gestion.Colegial.Entities;
using Gestion.Colegial.Entities.DTOs;
using Gestion.Colegial.Entities.Entities;
using Microsoft.AspNetCore.Mvc;

namespace Gestion.Colegial.Api.Controllers
{
    /// <summary>
    /// Sustitución de docente (espejo de Skuul "timetable substitutions"): docentes ausentes con sus
    /// clases del día y quién las cubre, suplentes sugeridos para una clase, docentes para marcar
    /// ausentes, historial con horas por suplente, y las escrituras.
    /// empId = alcance de lectura: sin él se ve todo; con él, solo lo de ese docente (lo decide el ADM
    /// con los permisos de la sesión). Las escrituras reciben Usuario y PuedeAsignar y siempre
    /// responden { Ok, Id, Estado, Mensaje }.
    /// </summary>
    [ApiController]
    [Route("api/v1/[controller]")]
    public class SustitucionesController : ControllerBase
    {
        private readonly ISustitucionesService _service;

        public SustitucionesController(ISustitucionesService service)
        {
            _service = service;
        }

        /// <summary>Lista vacía en vez de "" cuando la lectura falla (el ADM espera un arreglo).</summary>
        private static object Lista(Answer answer) => answer.Access || answer.Data is string ? Array.Empty<object>() : answer.Data;

        private static IActionResult Escritura(ControllerBase c, Answer answer, string general)
        {
            if (answer.Access || answer.Data is not PR_tbSustituciones_EscrituraResult r)
                return c.Ok(new { Ok = false, Id = 0, Estado = (string?)null, Mensaje = answer.Message ?? general });
            return c.Ok(new { Ok = true, r.Id, r.Estado, Mensaje = (string?)null });
        }

        [HttpGet]
        [Route("DiaAsync")]
        public async Task<IActionResult> Dia(DateTime? fecha, int? empId) => Ok(Lista(await _service.Dia(fecha, empId)));

        [HttpGet]
        [Route("MesAsync")]
        public async Task<IActionResult> Mes(DateTime? fecha, int? empId)
        {
            Answer answer = await _service.Mes(fecha, empId);
            return Ok(answer.Access ? null : answer.Data);
        }

        [HttpGet]
        [Route("SugerenciasAsync")]
        public async Task<IActionResult> Sugerencias(int horId, DateTime? fecha) => Ok(Lista(await _service.Sugerencias(horId, fecha)));

        [HttpGet]
        [Route("DocentesAsync")]
        public async Task<IActionResult> Docentes(DateTime? fecha) => Ok(Lista(await _service.Docentes(fecha)));

        [HttpGet]
        [Route("HistorialAsync")]
        public async Task<IActionResult> Historial(DateTime? desde, DateTime? hasta, int? empId) =>
            Ok(Lista(await _service.Historial(desde, hasta, empId)));

        [HttpPost]
        [Route("AsignarAsync")]
        public async Task<IActionResult> Asignar([FromBody] SustitucionAsignarDTO obj) =>
            Escritura(this, await _service.Asignar(obj), "No se pudo asignar el suplente.");

        [HttpPost]
        [Route("CancelarAsync")]
        public async Task<IActionResult> Cancelar([FromBody] SustitucionCancelarDTO obj) =>
            Escritura(this, await _service.Cancelar(obj), "No se pudo cancelar la sustitución.");

        [HttpPost]
        [Route("MarcarAusenciaAsync")]
        public async Task<IActionResult> MarcarAusencia([FromBody] AusenciaDocenteMarcarDTO obj) =>
            Escritura(this, await _service.MarcarAusencia(obj), "No se pudo marcar la ausencia.");

        [HttpPost]
        [Route("QuitarAusenciaAsync")]
        public async Task<IActionResult> QuitarAusencia([FromBody] AusenciaDocenteQuitarDTO obj) =>
            Escritura(this, await _service.QuitarAusencia(obj), "No se pudo quitar la ausencia.");
    }
}
