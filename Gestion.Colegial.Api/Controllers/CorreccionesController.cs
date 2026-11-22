using Gestion.Colegial.Business.Interfaces.ModuloFinanzas;
using Gestion.Colegial.Entities;
using Microsoft.AspNetCore.Mvc;

namespace Gestion.Colegial.Api.Controllers
{
    /// <summary>Registro de correcciones de cuenta de un alumno (anulaciones, perdones, saldo a favor).</summary>
    [ApiController]
    [Route("api/v1/[controller]")]
    public class CorreccionesController : ControllerBase
    {
        private readonly ICajaCorreccionesService _service;

        public CorreccionesController(ICajaCorreccionesService service)
        {
            _service = service;
        }

        /// <summary>Filas { Fecha, Tipo, Detalle, Motivo, Usuario, Monto }, más recientes primero.</summary>
        [HttpGet]
        [Route("ListByAlumnoAsync")]
        public async Task<IActionResult> ListByAlumno(int alumnoId)
        {
            Answer answer = await _service.CorreccionesPorAlumno(alumnoId);
            return Ok(answer.Data);
        }
    }
}
