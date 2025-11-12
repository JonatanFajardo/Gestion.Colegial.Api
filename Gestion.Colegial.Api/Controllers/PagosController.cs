using Gestion.Colegial.Business.Interfaces;
using Gestion.Colegial.Entities;
using Microsoft.AspNetCore.Mvc;

namespace Gestion.Colegial.Api.Controllers
{
    [ApiController]
    [Route("api/v1/[controller]")]
    public class PagosController : ControllerBase
    {
        private readonly IPagoService _pagoService;

        public PagosController(IPagoService pagoService)
        {
            _pagoService = pagoService;
        }

        [HttpGet]
        [Route("ListAsync")]
        public async Task<IActionResult> List()
        {
            Answer answer = await _pagoService.List();
            return Ok(answer.Data);
        }

        [HttpGet]
        [Route("ListByAlumnoAsync")]
        public async Task<IActionResult> ListByAlumno(int alumnoId)
        {
            Answer answer = await _pagoService.ListByAlumno(alumnoId);
            return Ok(answer.Data);
        }

        [HttpGet]
        [Route("ListByFechaAsync")]
        public async Task<IActionResult> ListByFecha(DateTime fecha)
        {
            Answer answer = await _pagoService.ListByFecha(fecha);
            return Ok(answer.Data);
        }

        [HttpGet]
        [Route("ListByRangoFechasAsync")]
        public async Task<IActionResult> ListByRangoFechas(DateTime fechaInicio, DateTime fechaFin)
        {
            Answer answer = await _pagoService.ListByRangoFechas(fechaInicio, fechaFin);
            return Ok(answer.Data);
        }

        [HttpGet]
        [Route("FindAsync")]
        public async Task<IActionResult> Find(int value)
        {
            Answer answer = await _pagoService.Find(value);
            return Ok(answer.Data);
        }

        [HttpGet]
        [Route("DetailAsync")]
        public async Task<IActionResult> Detail(int value)
        {
            Answer answer = await _pagoService.Detail(value);
            return Ok(answer.Data);
        }

        [HttpPost]
        [Route("CreateAsync")]
        public async Task<IActionResult> Create([FromBody] object entity)
        {
            Answer answer = await _pagoService.Create(entity);
            return Ok(answer.Data);
        }

        [HttpDelete]
        [Route("DeleteAsync")]
        public async Task<IActionResult> Delete(int value)
        {
            Answer answer = await _pagoService.Delete(value);
            return Ok(answer.Data);
        }

        [HttpGet]
        [Route("GetReciboAsync")]
        public async Task<IActionResult> GetRecibo(int pagoId)
        {
            Answer answer = await _pagoService.GetRecibo(pagoId);
            return Ok(answer.Data);
        }
    }
}
