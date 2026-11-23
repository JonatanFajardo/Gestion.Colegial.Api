using Gestion.Colegial.Business.Interfaces;
using Gestion.Colegial.Entities;
using Gestion.Colegial.Entities.DTOs;
using Gestion.Colegial.Entities.Entities;
using Microsoft.AspNetCore.Mvc;
using Gestion.Colegial.Api.Seguridad;

namespace Gestion.Colegial.Api.Controllers
{
    /// <summary>
    /// Cierre y publicación de parciales (script 075). Un período = (año, semestre, parcial).
    /// Lecturas: años, tablero con avance, faltantes por sección/materia/docente, historial y el estado
    /// simple de los períodos (para el cuaderno de notas y el boletín).
    /// Las escrituras siempre responden { Ok, Estado, Publicado, Mensaje }.
    /// </summary>
    [ApiController]
    [Route("api/v1/[controller]")]
    [DatoDelServidor(DatoUsuario.Usuario, "Usuario")]
    [PermisoDelServidor("Cerrar y publicar parciales", "PuedeCerrar")]
    public class CierresParcialController : ControllerBase
    {
        private readonly ICierresParcialService _service;

        public CierresParcialController(ICierresParcialService service)
        {
            _service = service;
        }

        /// <summary>Lista vacía en vez de "" cuando la lectura falla (el ADM espera un arreglo).</summary>
        private static object Lista(Answer answer) => answer.Access || answer.Data is string ? Array.Empty<object>() : answer.Data;

        private static object Respuesta(Answer answer, string general)
        {
            if (answer.Access || answer.Data is not PR_CierresParcial_EscrituraResult r)
                return new { Ok = false, Estado = (string?)null, Publicado = false, Mensaje = answer.Message ?? general };
            return new { Ok = true, Estado = r.Estado, Publicado = r.Publicado, Mensaje = (string?)null };
        }

        [HttpGet]
        [Route("AniosAsync")]
        public async Task<IActionResult> Anios() => Ok(Lista(await _service.Anios()));

        [HttpGet]
        [Route("EstadoAsync")]
        public async Task<IActionResult> Estado(int anio) => Ok(Lista(await _service.Estado(anio)));

        [HttpGet]
        [Route("FaltantesAsync")]
        public async Task<IActionResult> Faltantes(int anio, int semId, int pacId) => Ok(Lista(await _service.Faltantes(anio, semId, pacId)));

        [HttpGet]
        [Route("HistorialAsync")]
        public async Task<IActionResult> Historial(int anio) => Ok(Lista(await _service.Historial(anio)));

        /// <summary>Estado de los períodos de un año (filtrable por semestre/parcial) o el de una nota (notId).</summary>
        [HttpGet]
        [Route("PeriodosAsync")]
        public async Task<IActionResult> Periodos(int? anio = null, int? semId = null, int? pacId = null, int? notId = null) =>
            Ok(Lista(await _service.Periodos(anio, semId, pacId, notId)));

        [HttpPost]
        [Route("CerrarAsync")]
        public async Task<IActionResult> Cerrar([FromBody] CierreParcialAccionDTO obj) =>
            Ok(Respuesta(await _service.Cerrar(obj), "No se pudo cerrar el parcial."));

        [HttpPost]
        [Route("PublicarAsync")]
        public async Task<IActionResult> Publicar([FromBody] CierreParcialAccionDTO obj) =>
            Ok(Respuesta(await _service.Publicar(obj), "No se pudieron publicar los resultados."));

        [HttpPost]
        [Route("DespublicarAsync")]
        public async Task<IActionResult> Despublicar([FromBody] CierreParcialAccionDTO obj) =>
            Ok(Respuesta(await _service.Despublicar(obj), "No se pudo retirar la publicación."));

        [HttpPost]
        [Route("ReabrirAsync")]
        public async Task<IActionResult> Reabrir([FromBody] CierreParcialAccionDTO obj) =>
            Ok(Respuesta(await _service.Reabrir(obj), "No se pudo reabrir el parcial."));

        [HttpPost]
        [Route("FechasAsync")]
        public async Task<IActionResult> Fechas([FromBody] CierreParcialAccionDTO obj) =>
            Ok(Respuesta(await _service.Fechas(obj), "No se pudieron guardar las fechas."));
    }
}
