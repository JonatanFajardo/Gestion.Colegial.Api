using Gestion.Colegial.Business.Interfaces;
using Gestion.Colegial.Entities;
using Gestion.Colegial.Entities.DTOs.finansas;
using Microsoft.AspNetCore.Mvc;
using Gestion.Colegial.Business.Interfaces.ModuloFinanzas;
using Gestion.Colegial.Api.Seguridad;

namespace Gestion.Colegial.Api.Controllers
{
    [ApiController]
    [Route("api/v1/[controller]")]
    public class PagosController : ControllerBase
    {
        private readonly IPagoService _pagoService;
        private readonly ICajaCorreccionesService _correcciones;

        public PagosController(IPagoService pagoService, ICajaCorreccionesService correcciones)
        {
            _pagoService = pagoService;
            _correcciones = correcciones;
        }

        /// <summary>
        /// Anula un pago (no lo borra): lo que cubría vuelve a pendiente y el dinero
        /// se devuelve o pasa a saldo a favor. Responde { Access, Message, Data }.
        /// </summary>
        [HttpPost]
        [Route("AnularAsync")]
        [DatoDelServidor(DatoUsuario.Usuario, "UsuarioId")]
        [RequierePantalla("Corregir cuentas")]
        public async Task<IActionResult> Anular([FromBody] PagoAnularDto entity)
        {
            Answer answer = await _correcciones.AnularPago(entity);
            return Ok(answer);
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
        [DatoDelServidor(DatoUsuario.Usuario, "UsuarioId")]
        [RequierePantalla("Crear pagos")]
        public async Task<IActionResult> Create([FromBody] PagoFindDto entity)
        {
            Answer answer = await _pagoService.Create(entity);
            if (answer.Access)
                return BadRequest(answer.Message);
            return Ok(answer.Data);
        }

        [HttpDelete]
        [Route("DeleteAsync")]
        [RequierePantalla("Eliminar pagos")]
        public async Task<IActionResult> Delete(int value)
        {
            Answer answer = await _pagoService.Delete(value);
            return Ok(answer.Data);
        }

        [HttpGet]
        [Route("GetReciboAsync")]
        [RequierePantalla("Crear pagos|Comprobante de pago|Corregir cuentas")]
        public async Task<IActionResult> GetRecibo(int pagoId)
        {
            Answer answer = await _pagoService.GetRecibo(pagoId);
            return Ok(answer.Data);
        }
    }
}
