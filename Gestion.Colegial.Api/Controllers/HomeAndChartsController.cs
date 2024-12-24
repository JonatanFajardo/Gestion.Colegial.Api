using Gestion.Colegial.Business.Services;
using Gestion.Colegial.Entities;
using Microsoft.AspNetCore.Mvc;

namespace Gestion.Colegial.Api.Controllers
{
    [ApiController]
    [Route("api/v1/[controller]")]
    public class HomeAndChartsController : Controller
    {
        private readonly HomeAndChartsService _homeAndChartsService;

        public HomeAndChartsController(HomeAndChartsService homeAndChartsService)
        {
            _homeAndChartsService = homeAndChartsService;
        }

        /// <summary>
        /// Obtiene datos comparativos de la cantidad de alumnos entre el año pasado y el actual para el dashboard principal.
        /// </summary>
        /// <returns>Datos relacionados con la comparación de alumnos por año.</returns>
        /// <response code="200">Ok. Devuelve los datos de comparación correctamente.</response>
        /// <response code="404">NotFound. No se encontraron datos para la comparación.</response>
        [HttpGet("HomeAndChartsList")]
        public async Task<IActionResult> HomeAndCharts()
        {
            Answer answer = await _homeAndChartsService.DiferenciaEntreCantidadAlumnosAnioPasado_Dashboard();
            return Ok(answer.Data);
        }

        /// <summary>
        /// Obtiene la cantidad de alumnos por curso para generar estadísticas y gráficos.
        /// </summary>
        /// <returns>Lista con la cantidad de alumnos por curso.</returns>
        /// <response code="200">Ok. Devuelve la lista de alumnos por curso.</response>
        /// <response code="404">NotFound. No se encontraron datos de alumnos por curso.</response>
        [HttpGet("ObtenerCantidadAlumnosPorCursoList")]
        public async Task<IActionResult> ObtenerCantidadAlumnosPorCursoList()
        {
            Answer answer = await _homeAndChartsService.ObtenerCantidadAlumnosPorCursoList();
            return Ok(answer.Data);
        }

        /// <summary>
        /// Calcula el promedio de alumnos por curso durante los últimos años.
        /// </summary>
        /// <returns>Datos del promedio de alumnos por curso en los últimos años.</returns>
        /// <response code="200">Ok. Devuelve el promedio de alumnos por curso.</response>
        /// <response code="404">NotFound. No se encontraron datos para calcular el promedio.</response>
        [HttpGet("ObtenerPromedioCursoUltimosAnios")]
        public async Task<IActionResult> ObtenerPromedioCursoUltimosAnios()
        {
            Answer answer = await _homeAndChartsService.ObtenerPromedioCursoUltimosAnios();
            return Ok(answer.Data);
        }

        /// <summary>
        /// Recupera datos de las tarjetas principales que se muestran en la pantalla de inicio del sistema.
        /// </summary>
        /// <returns>Lista de tarjetas con datos relevantes para el dashboard de inicio.</returns>
        /// <response code="200">Ok. Devuelve la lista de tarjetas correctamente.</response>
        /// <response code="404">NotFound. No se encontraron tarjetas para mostrar en la pantalla de inicio.</response>
        [HttpGet("CardsInHomeList")]
        public async Task<IActionResult> CardsInHomeList()
        {
            Answer answer = await _homeAndChartsService.CardsInHomeList();
            return Ok(answer.Data);
        }

    }
}
