using Gestion.Colegial.Business.Interfaces;
using Gestion.Colegial.Entities;
using Gestion.Colegial.Entities.DTOs;
using Gestion.Colegial.Entities.Entities;
using Microsoft.AspNetCore.Mvc;
using Gestion.Colegial.Api.Seguridad;

namespace Gestion.Colegial.Api.Controllers
{
    /// <summary>
    /// Temario y avance del programa (espejo de Skuul "syllabus"): biblioteca de temarios, temas por semana,
    /// secciones que llevan la materia con su avance, marcas de avance, resumen de Dirección y materias sin
    /// temario. Cada pedido trae el usuario (usuId o Usuario): el procedimiento decide qué puede ver y hacer.
    /// Las escrituras siempre responden { Ok, Id, Tem_Id, Cantidad, Mensaje }.
    /// </summary>
    [ApiController]
    [Route("api/v1/[controller]")]
    [DatoDelServidor(DatoUsuario.Usuario, "usuId", "Usuario")]
    public class TemariosController : ControllerBase
    {
        private readonly ITemariosService _service;

        public TemariosController(ITemariosService service)
        {
            _service = service;
        }

        /// <summary>Lista vacía en vez de "" cuando la lectura falla (el ADM espera un arreglo).</summary>
        private static object Lista(Answer answer) => answer.Access || answer.Data is string ? Array.Empty<object>() : answer.Data;

        private IActionResult Escritura(Answer answer, string general)
        {
            if (answer.Access || answer.Data is not PR_tbTemarios_EscrituraResult r)
                return Ok(new { Ok = false, Id = 0, Tem_Id = 0, Cantidad = 0, Mensaje = answer.Message ?? general });
            return Ok(new { Ok = true, r.Id, r.Tem_Id, r.Cantidad, Mensaje = (string?)null });
        }

        [HttpGet]
        [Route("ListAsync")]
        public async Task<IActionResult> List(int usuId) => Ok(Lista(await _service.List(usuId)));

        /// <summary>Un temario; respuesta vacía si no existe o la persona no lo puede leer.</summary>
        [HttpGet]
        [Route("FindAsync")]
        public async Task<IActionResult> Find(int value, int usuId)
        {
            Answer answer = await _service.Find(value, usuId);
            return Ok(answer.Access ? null : answer.Data);
        }

        [HttpGet]
        [Route("TemasAsync")]
        public async Task<IActionResult> Temas(int value, int usuId) => Ok(Lista(await _service.Temas(value, usuId)));

        [HttpGet]
        [Route("GruposAsync")]
        public async Task<IActionResult> Grupos(int value, int usuId) => Ok(Lista(await _service.Grupos(value, usuId)));

        [HttpGet]
        [Route("AvanceAsync")]
        public async Task<IActionResult> Avance(int value, int usuId) => Ok(Lista(await _service.Avance(value, usuId)));

        /// <summary>Resumen de Dirección (solo con "Supervisar temarios"; si no, lista vacía).</summary>
        [HttpGet]
        [Route("ResumenAsync")]
        public async Task<IActionResult> Resumen(int usuId, int? anio = null, int? semId = null) =>
            Ok(Lista(await _service.Resumen(usuId, anio, semId)));

        [HttpGet]
        [Route("SinTemarioAsync")]
        public async Task<IActionResult> SinTemario(int usuId, int? anio = null, int? semId = null) =>
            Ok(Lista(await _service.SinTemario(usuId, anio, semId)));

        /// <summary>Opciones de los filtros: tipo = nivel | grado (nivId) | curso (cunId) | materia (cunId, curId) | semestre | anio.</summary>
        [HttpGet]
        [Route("OpcionesAsync")]
        public async Task<IActionResult> Opciones(int usuId, string? tipo, int? nivId = null, int? cunId = null, int? curId = null, int? anio = null) =>
            Ok(Lista(await _service.Opciones(usuId, tipo, nivId, cunId, curId, anio)));

        /// <summary>Temas del temario de un horario para una semana (para "Plan de clases").</summary>
        [HttpGet]
        [Route("TemasDeHorarioAsync")]
        public async Task<IActionResult> TemasDeHorario(int horId, int semana, int usuId) =>
            Ok(Lista(await _service.TemasDeHorario(horId, semana, usuId)));

        [HttpPost]
        [Route("CrearAsync")]
        public async Task<IActionResult> Crear([FromBody] TemarioGuardarDTO obj) =>
            Escritura(await _service.Crear(obj), "No se pudo crear el temario.");

        [HttpPost]
        [Route("EditarAsync")]
        public async Task<IActionResult> Editar([FromBody] TemarioGuardarDTO obj) =>
            Escritura(await _service.Editar(obj), "No se pudieron guardar los cambios del temario.");

        [HttpPost]
        [Route("EliminarAsync")]
        public async Task<IActionResult> Eliminar([FromBody] TemarioEliminarDTO obj) =>
            Escritura(await _service.Eliminar(obj), "No se pudo quitar el temario.");

        [HttpPost]
        [Route("CopiarAsync")]
        public async Task<IActionResult> Copiar([FromBody] TemarioCopiarDTO obj) =>
            Escritura(await _service.Copiar(obj), "No se pudo copiar el temario.");

        [HttpPost]
        [Route("GuardarTemaAsync")]
        public async Task<IActionResult> GuardarTema([FromBody] TemarioTemaDTO obj) =>
            Escritura(await _service.GuardarTema(obj), "No se pudo guardar el tema.");

        [HttpPost]
        [Route("MoverTemaAsync")]
        public async Task<IActionResult> MoverTema([FromBody] TemarioTemaAccionDTO obj) =>
            Escritura(await _service.MoverTema(obj), "No se pudo mover el tema.");

        [HttpPost]
        [Route("QuitarTemaAsync")]
        public async Task<IActionResult> QuitarTema([FromBody] TemarioTemaAccionDTO obj) =>
            Escritura(await _service.QuitarTema(obj), "No se pudo quitar el tema.");

        [HttpPost]
        [Route("MarcarAvanceAsync")]
        public async Task<IActionResult> MarcarAvance([FromBody] TemarioAvanceDTO obj) =>
            Escritura(await _service.MarcarAvance(obj), "No se pudo guardar el avance.");

        [HttpPost]
        [Route("QuitarAvanceAsync")]
        public async Task<IActionResult> QuitarAvance([FromBody] TemarioAvanceDTO obj) =>
            Escritura(await _service.QuitarAvance(obj), "No se pudo quitar la marca de avance.");
    }
}
