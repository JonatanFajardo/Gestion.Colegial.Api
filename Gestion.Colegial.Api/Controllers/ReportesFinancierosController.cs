using Gestion.Colegial.Business.Interfaces;
using Gestion.Colegial.Entities;
using Microsoft.AspNetCore.Mvc;
using Gestion.Colegial.Business.Interfaces.ModuloFinanzas;

namespace Gestion.Colegial.Api.Controllers
{
    [ApiController]
    [Route("api/v1/[controller]")]
    public class ReportesFinancierosController : ControllerBase
    {
        private readonly IReporteFinancieroService _reporteFinancieroService;

        public ReportesFinancierosController(IReporteFinancieroService reporteFinancieroService)
        {
            _reporteFinancieroService = reporteFinancieroService;
        }

        [HttpGet]
        [Route("IngresosPorMesAsync")]
        public async Task<IActionResult> IngresosPorMes(int anio, int mes)
        {
            Answer answer = await _reporteFinancieroService.IngresosPorMes(anio, mes);
            return Ok(answer.Data);
        }

        [HttpGet]
        [Route("ProyeccionCobrosAsync")]
        public async Task<IActionResult> ProyeccionCobros(int anio, int mes)
        {
            Answer answer = await _reporteFinancieroService.ProyeccionCobros(anio, mes);
            return Ok(answer.Data);
        }

        [HttpGet]
        [Route("ListadoMorososAsync")]
        public async Task<IActionResult> ListadoMorosos()
        {
            Answer answer = await _reporteFinancieroService.ListadoMorosos();
            return Ok(answer.Data);
        }

        [HttpGet]
        [Route("EstadoCuentaAlumnoAsync")]
        public async Task<IActionResult> EstadoCuentaAlumno(int alumnoId)
        {
            Answer answer = await _reporteFinancieroService.EstadoCuentaAlumno(alumnoId);
            return Ok(answer.Data);
        }

        [HttpGet]
        [Route("ComparativaAnualAsync")]
        public async Task<IActionResult> ComparativaAnual(int anioInicio, int anioFin)
        {
            Answer answer = await _reporteFinancieroService.ComparativaAnual(anioInicio, anioFin);
            return Ok(answer.Data);
        }
    }
}
