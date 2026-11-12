using Gestion.Colegial.Business.Interfaces;
using Gestion.Colegial.Entities;
using Microsoft.AspNetCore.Mvc;

namespace Gestion.Colegial.Api.Controllers
{
    /// <summary>
    /// Reporte de asistencia de alumnos (solo lectura). Fechas en la URL como yyyy-MM-dd.
    /// Con empId (docente sin permiso de ver todas las secciones) solo salen las secciones de ese docente.
    /// </summary>
    [ApiController]
    [Route("api/v1/[controller]")]
    public class ReporteAsistenciaController : ControllerBase
    {
        private readonly IReporteAsistenciaService _service;

        public ReporteAsistenciaController(IReporteAsistenciaService service)
        {
            _service = service;
        }

        /// <summary>Año lectivo que contiene la fecha; respuesta vacía si no hay.</summary>
        [HttpGet]
        [Route("AnioAsync")]
        public async Task<IActionResult> Anio(DateTime fecha)
        {
            Answer answer = await _service.Anio(fecha);
            return Ok(answer.Data);
        }

        [HttpGet]
        [Route("PeriodosAsync")]
        public async Task<IActionResult> Periodos(int aniId) => Ok((await _service.Periodos(aniId)).Data);

        /// <summary>Secciones del año (con empId, solo las del docente) para los filtros en cascada.</summary>
        [HttpGet]
        [Route("FiltrosAsync")]
        public async Task<IActionResult> Filtros(int aniId, int? empId = null) => Ok((await _service.Filtros(aniId, empId)).Data);

        /// <summary>Resumen por sección en el rango; se puede cortar por nivel, grado o sección.</summary>
        [HttpGet]
        [Route("SeccionesAsync")]
        public async Task<IActionResult> Secciones(int aniId, DateTime desde, DateTime hasta, int? nivId = null, int? cunId = null,
                                                   int? seaId = null, int? empId = null)
        {
            Answer answer = await _service.Secciones(aniId, desde, hasta, nivId, cunId, seaId, empId);
            return Ok(answer.Data);
        }

        /// <summary>Cabecera de una sección; respuesta vacía si no existe.</summary>
        [HttpGet]
        [Route("SeccionInfoAsync")]
        public async Task<IActionResult> SeccionInfo(int seaId)
        {
            Answer answer = await _service.SeccionInfo(seaId);
            return Ok(answer.Data);
        }

        [HttpGet]
        [Route("AlumnosAsync")]
        public async Task<IActionResult> Alumnos(int seaId, DateTime desde, DateTime hasta) =>
            Ok((await _service.Alumnos(seaId, desde, hasta)).Data);

        /// <summary>Días lunes a viernes del rango (hasta hoy), con cierres y si tienen registro.</summary>
        [HttpGet]
        [Route("DiasAsync")]
        public async Task<IActionResult> Dias(int seaId, DateTime desde, DateTime hasta) =>
            Ok((await _service.Dias(seaId, desde, hasta)).Data);

        /// <summary>Estado diario de cada alumno (P, T, A, J).</summary>
        [HttpGet]
        [Route("PlanillaAsync")]
        public async Task<IActionResult> Planilla(int seaId, DateTime desde, DateTime hasta) =>
            Ok((await _service.Planilla(seaId, desde, hasta)).Data);
    }
}
