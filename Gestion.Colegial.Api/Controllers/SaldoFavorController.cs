using Gestion.Colegial.Business.Interfaces.ModuloFinanzas;
using Gestion.Colegial.Entities;
using Gestion.Colegial.Entities.DTOs.finansas;
using Microsoft.AspNetCore.Mvc;
using Gestion.Colegial.Api.Seguridad;

namespace Gestion.Colegial.Api.Controllers
{
    /// <summary>
    /// Saldo a favor del alumno (dinero que el colegio le guarda). Saldo = suma de movimientos.
    /// Las escrituras responden { Access, Message, Data }.
    /// </summary>
    [ApiController]
    [Route("api/v1/[controller]")]
    public class SaldoFavorController : ControllerBase
    {
        private readonly ICajaCorreccionesService _service;

        public SaldoFavorController(ICajaCorreccionesService service)
        {
            _service = service;
        }

        /// <summary>{ AlumnoId, Saldo }</summary>
        [HttpGet]
        [Route("ObtenerAsync")]
        public async Task<IActionResult> Obtener(int alumnoId)
        {
            Answer answer = await _service.ObtenerSaldoFavor(alumnoId);
            return Ok(answer.Data);
        }

        [HttpPost]
        [Route("DevolverAsync")]
        [DatoDelServidor(DatoUsuario.Usuario, "UsuarioId")]
        [RequierePantalla("Corregir cuentas")]
        public async Task<IActionResult> Devolver([FromBody] SaldoFavorDevolverDto entity)
        {
            Answer answer = await _service.DevolverSaldoFavor(entity);
            return Ok(answer);
        }

        [HttpPost]
        [Route("AplicarAsync")]
        [DatoDelServidor(DatoUsuario.Usuario, "UsuarioId")]
        [RequierePantalla("Corregir cuentas")]
        public async Task<IActionResult> Aplicar([FromBody] SaldoFavorAplicarDto entity)
        {
            Answer answer = await _service.AplicarSaldoFavor(entity);
            return Ok(answer);
        }
    }
}
