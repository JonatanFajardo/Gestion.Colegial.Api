using Gestion.Colegial.Business.Interfaces;
using Gestion.Colegial.Entities;
using Gestion.Colegial.Entities.DTOs;
using Microsoft.AspNetCore.Mvc;
using Gestion.Colegial.Api.Seguridad;

namespace Gestion.Colegial.Api.Controllers
{
    /// <summary>
    /// Cierre del año escolar (script 090). Lecturas: resumen, revisión, reglas por nivel, secciones,
    /// resultados, decisiones e historial. Escrituras: estado del año, calcular, regla, recuperación,
    /// decisión, confirmar y deshacer sección; siempre responden { Ok, Mensaje, Datos }.
    /// Pide la pantalla "Cierre del año" (o "Cerrar el año"); el usuario y los permisos de escritura los
    /// pone la API con el usuario firmado.
    /// </summary>
    [ApiController]
    [Route("api/v1/[controller]")]
    [RequierePantalla("Cierre del año|Cerrar el año")]
    [DatoDelServidor(DatoUsuario.Usuario, "Usuario")]
    [PermisoDelServidor("Cerrar el año", "PuedeCerrar")]
    [PermisoDelServidor("Reabrir el año escolar", "PuedeReabrir")]
    public class CierreAnioController : ControllerBase
    {
        private readonly ICierreAnioService _service;

        public CierreAnioController(ICierreAnioService service)
        {
            _service = service;
        }

        /// <summary>Lista vacía en vez de "" cuando la lectura falla (el ADM espera un arreglo).</summary>
        private static object Lista(Answer answer) => answer.Access || answer.Data is string ? Array.Empty<object>() : answer.Data;

        private static object Respuesta(Answer answer, string general) =>
            answer.Access || answer.Data is string
                ? new { Ok = false, Mensaje = answer.Message ?? general, Datos = (object?)null }
                : new { Ok = true, Mensaje = (string?)null, Datos = answer.Data };

        [HttpGet]
        [Route("ResumenAsync")]
        public async Task<IActionResult> Resumen(int aniId)
        {
            Answer answer = await _service.Resumen(aniId);
            return Ok(answer.Access || answer.Data is string ? null : answer.Data);
        }

        [HttpGet]
        [Route("RevisionAsync")]
        public async Task<IActionResult> Revision(int aniId) => Ok(Lista(await _service.Revision(aniId)));

        [HttpGet]
        [Route("ReglasAsync")]
        public async Task<IActionResult> Reglas(int aniId) => Ok(Lista(await _service.Reglas(aniId)));

        [HttpGet]
        [Route("SeccionesAsync")]
        public async Task<IActionResult> Secciones(int aniId) => Ok(Lista(await _service.Secciones(aniId)));

        [HttpGet]
        [Route("ResultadosAsync")]
        public async Task<IActionResult> Resultados(int aniId, int seaId) => Ok(Lista(await _service.Resultados(aniId, seaId)));

        [HttpGet]
        [Route("DecisionesAsync")]
        public async Task<IActionResult> Decisiones(int aniId, int seaId) => Ok(Lista(await _service.Decisiones(aniId, seaId)));

        [HttpGet]
        [Route("HistorialAsync")]
        public async Task<IActionResult> Historial(int aniId) => Ok(Lista(await _service.Historial(aniId)));

        [HttpPost]
        [Route("EstadoAsync")]
        public async Task<IActionResult> Estado([FromBody] CierreAnioAccionDTO obj) =>
            Ok(Respuesta(await _service.CambiarEstado(obj), "No se pudo cambiar el estado del año."));

        [HttpPost]
        [Route("CalcularAsync")]
        public async Task<IActionResult> Calcular([FromBody] CierreAnioAccionDTO obj) =>
            Ok(Respuesta(await _service.Calcular(obj), "No se pudieron calcular los resultados."));

        [HttpPost]
        [Route("ReglaAsync")]
        public async Task<IActionResult> Regla([FromBody] CierreAnioAccionDTO obj) =>
            Ok(Respuesta(await _service.GuardarRegla(obj), "No se pudo guardar la regla."));

        [HttpPost]
        [Route("RecuperacionAsync")]
        public async Task<IActionResult> Recuperacion([FromBody] CierreAnioAccionDTO obj) =>
            Ok(Respuesta(await _service.Recuperacion(obj), "No se pudo guardar la nota de recuperación."));

        [HttpPost]
        [Route("DecisionAsync")]
        public async Task<IActionResult> Decision([FromBody] CierreAnioAccionDTO obj) =>
            Ok(Respuesta(await _service.Decidir(obj), "No se pudo guardar la decisión."));

        [HttpPost]
        [Route("ConfirmarSeccionAsync")]
        public async Task<IActionResult> ConfirmarSeccion([FromBody] CierreAnioAccionDTO obj) =>
            Ok(Respuesta(await _service.ConfirmarSeccion(obj), "No se pudieron confirmar las decisiones."));

        [HttpPost]
        [Route("DeshacerSeccionAsync")]
        public async Task<IActionResult> DeshacerSeccion([FromBody] CierreAnioAccionDTO obj) =>
            Ok(Respuesta(await _service.DeshacerSeccion(obj), "No se pudo deshacer la confirmación."));
    }
}
