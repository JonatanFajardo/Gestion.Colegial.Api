using Gestion.Colegial.Business.Interfaces;
using Gestion.Colegial.Entities;
using Microsoft.AspNetCore.Mvc;

namespace Gestion.Colegial.Api.Controllers
{
    /// <summary>
    /// Rollover (RollForward) de la estructura del año lectivo. Copia períodos,
    /// secciones y ofertas de un año origen a un año destino como borrador,
    /// sin arrastrar alumnos ni docentes. Re-ejecutable (salta lo que ya exista).
    /// </summary>
    [ApiController]
    [Route("api/v1/[controller]")]
    public class RolloverController : ControllerBase
    {
        private readonly IRolloverService _rolloverService;

        public RolloverController(IRolloverService rolloverService)
        {
            _rolloverService = rolloverService;
        }

        /// <summary>Arrastra la estructura del año <paramref name="origen"/> al año <paramref name="destino"/> (ambos = Ani_Anio).</summary>
        [HttpPost]
        [Route("RollForwardAsync")]
        public async Task<IActionResult> RollForward(int origen, int destino)
        {
            Answer answer = await _rolloverService.RollForward(origen, destino);
            if (answer.Access)
            {
                return BadRequest(answer.Message);
            }
            return Ok(answer.Data);
        }
    }
}
