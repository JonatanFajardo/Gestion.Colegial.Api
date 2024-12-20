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
        /// Obtiene un objeto.
        /// </summary>
        /// <returns>Objeto tbAlumnos.</returns>
        /// <response code="200">Ok. Devuelve el objeto solicitado.</response>
        /// <response code="404">NotFound. No se ha encontrado el objeto solicitado.</response>
        [HttpGet("HomeAndChartsList")]
        //[ResponseType(typeof(tbAlumnos))]
        //[Route("ListAsync")]
        public async Task<IActionResult> HomeAndCharts()
        {
            Answer answer = await _homeAndChartsService.DiferenciaEntreCantidadAlumnosAnioPasado_Dashboard();
            return Ok(answer.Data);
        }

        /// <summary>
        /// Obtiene un objeto.
        /// </summary>
        /// <returns>Objeto tbAlumnos.</returns>
        /// <response code="200">Ok. Devuelve el objeto solicitado.</response>
        /// <response code="404">NotFound. No se ha encontrado el objeto solicitado.</response>
        [HttpGet("ObtenerCantidadAlumnosPorCursoList")]
        //[ResponseType(typeof(tbAlumnos))]
        //[Route("ListAsync")]
        public async Task<IActionResult> ObtenerCantidadAlumnosPorCursoList()
        {
            Answer answer = await _homeAndChartsService.ObtenerCantidadAlumnosPorCursoList();
            return Ok(answer.Data);
        }
    }
}
