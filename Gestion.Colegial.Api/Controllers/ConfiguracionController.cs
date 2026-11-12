using Gestion.Colegial.Business.Interfaces;
using Gestion.Colegial.Entities;
using Microsoft.AspNetCore.Mvc;
using System.Threading.Tasks;

namespace Gestion.Colegial.Api.Controllers
{
    [ApiController]
    [Route("api/v1/[controller]")]
    public class ConfiguracionController : ControllerBase
    {
        private readonly IConfiguracionService _service;
        public ConfiguracionController(IConfiguracionService service) { _service = service; }

        [HttpGet("ListAsync")]
        public async Task<IActionResult> List()
        {
            Answer answer = await _service.List();
            return Ok(answer.Data);
        }

        [HttpPut("UpdateAsync")]
        public async Task<IActionResult> Update([FromBody] ConfiguracionUpdateRequest request)
        {
            Answer answer = await _service.Update(request.Con_Id, request.Con_Valor, request.UsuarioModifica);
            return Ok(answer);
        }

        /// <summary>
        /// Devuelve { Clave, Valor } para nota_minima_aprobacion (consumido por el MVC).
        /// </summary>
        [HttpGet("NotaMinimaAprobacionAsync")]
        public async Task<IActionResult> GetNotaMinimaAprobacion()
        {
            Answer answer = await _service.GetNotaMinimaAprobacion();
            if (answer.Access) return BadRequest(answer.Message ?? "Error consultando nota minima.");
            return Ok(answer.Data);
        }

        /// <summary>
        /// Persiste el valor de nota_minima_aprobacion (0-100). UPSERT por Con_Clave.
        /// </summary>
        [HttpPut("NotaMinimaAprobacionAsync")]
        public async Task<IActionResult> SetNotaMinimaAprobacion([FromQuery] decimal valor, [FromQuery] int usuarioId)
        {
            if (valor < 0m || valor > 100m) return BadRequest("El valor debe estar en el rango 0-100.");
            if (usuarioId <= 0) return BadRequest("usuarioId requerido.");

            Answer answer = await _service.SetNotaMinimaAprobacion(valor, usuarioId);
            if (answer.Access) return BadRequest(answer.Message ?? "Error guardando nota minima.");
            return Ok(new { Clave = "nota_minima_aprobacion", Valor = valor.ToString(System.Globalization.CultureInfo.InvariantCulture) });
        }
    }

    public class ConfiguracionUpdateRequest
    {
        public int Con_Id { get; set; }
        public string Con_Valor { get; set; }
        public int UsuarioModifica { get; set; }
    }
}
