using Gestion.Colegial.Business.Interfaces;
using Gestion.Colegial.Entities;
using Gestion.Colegial.Entities.DTOs;
using Gestion.Colegial.Entities.Entities;
using Microsoft.AspNetCore.Mvc;

namespace Gestion.Colegial.Api.Controllers
{
    /// <summary>
    /// Plan de apoyo al alumno (espejo de Skuul "support plans"): directorio, indicadores, el plan con sus
    /// pasos, notas e historial, y los planes abiertos de una lista de alumnos.
    /// Quién lee: verTodos (gestiona planes), verConfidenciales y usuId. Un plan confidencial solo lo leen
    /// quien tiene el permiso, el responsable o quien lo creó; sin verTodos solo se ven los planes propios
    /// (responsable, creador o con un paso asignado).
    /// Las escrituras siempre responden { Ok, Id, Estado, Version, Mensaje }.
    /// </summary>
    [ApiController]
    [Route("api/v1/[controller]")]
    public class PlanesApoyoController : ControllerBase
    {
        private readonly IPlanesApoyoService _service;

        public PlanesApoyoController(IPlanesApoyoService service)
        {
            _service = service;
        }

        /// <summary>Lista vacía en vez de "" cuando la lectura falla (el ADM espera un arreglo).</summary>
        private static object Lista(Answer answer) => answer.Access || answer.Data is string ? Array.Empty<object>() : answer.Data;

        private static object Fallo(Answer answer, string general) =>
            new { Ok = false, Id = 0, Estado = (string?)null, Version = 0, Mensaje = answer.Message ?? general };

        private static object Exito(int id, string? estado = null, int version = 0) =>
            new { Ok = true, Id = id, Estado = estado, Version = version, Mensaje = (string?)null };

        [HttpGet]
        [Route("ListAsync")]
        public async Task<IActionResult> List(bool verTodos = false, bool verConfidenciales = false, int? usuId = null) =>
            Ok(Lista(await _service.List(verTodos, verConfidenciales, usuId)));

        [HttpGet]
        [Route("ResumenAsync")]
        public async Task<IActionResult> Resumen(bool verTodos = false, bool verConfidenciales = false, int? usuId = null)
        {
            Answer answer = await _service.Resumen(verTodos, verConfidenciales, usuId);
            return Ok(answer.Access ? null : answer.Data);
        }

        /// <summary>Un plan; respuesta vacía si no existe o la persona no lo puede leer.</summary>
        [HttpGet]
        [Route("FindAsync")]
        public async Task<IActionResult> Find(int value, bool verTodos = false, bool verConfidenciales = false, int? usuId = null)
        {
            Answer answer = await _service.Find(value, verTodos, verConfidenciales, usuId);
            return Ok(answer.Access ? null : answer.Data);
        }

        [HttpGet]
        [Route("PasosAsync")]
        public async Task<IActionResult> Pasos(int value, bool verTodos = false, bool verConfidenciales = false, int? usuId = null) =>
            Ok(Lista(await _service.Pasos(value, verTodos, verConfidenciales, usuId)));

        [HttpGet]
        [Route("NotasAsync")]
        public async Task<IActionResult> Notas(int value, bool verTodos = false, bool verConfidenciales = false, int? usuId = null) =>
            Ok(Lista(await _service.Notas(value, verTodos, verConfidenciales, usuId)));

        [HttpGet]
        [Route("EstadosAsync")]
        public async Task<IActionResult> Estados(int value, bool verTodos = false, bool verConfidenciales = false, int? usuId = null) =>
            Ok(Lista(await _service.Estados(value, verTodos, verConfidenciales, usuId)));

        /// <summary>Usuarios que pueden ser responsables (admin, director o Docente activos).</summary>
        [HttpGet]
        [Route("UsuariosAsync")]
        public async Task<IActionResult> Usuarios() => Ok(Lista(await _service.Usuarios()));

        /// <summary>Alumnos activos a los que se les puede abrir un plan.</summary>
        [HttpGet]
        [Route("AlumnosAsync")]
        public async Task<IActionResult> Alumnos() => Ok(Lista(await _service.Alumnos()));

        /// <summary>Secciones de un grado con alumnos activos (filtro en cascada Nivel → Grado → Sección).</summary>
        [HttpGet]
        [Route("SeccionesAsync")]
        public async Task<IActionResult> Secciones(int cunId) => Ok(Lista(await _service.Secciones(cunId)));

        /// <summary>Planes abiertos legibles de los alumnos "1,2,3".</summary>
        [HttpGet]
        [Route("AbiertosAsync")]
        public async Task<IActionResult> Abiertos(string? alumnos, bool verTodos = false, bool verConfidenciales = false, int? usuId = null) =>
            Ok(Lista(await _service.AbiertosDeAlumnos(alumnos, verTodos, verConfidenciales, usuId)));

        [HttpPost]
        [Route("CrearAsync")]
        public async Task<IActionResult> Crear([FromBody] PlanApoyoGuardarDTO obj)
        {
            Answer answer = await _service.Crear(obj);
            if (answer.Access || answer.Data is not PR_tbPlanesApoyo_EscrituraResult r)
                return Ok(Fallo(answer, "No se pudo abrir el plan."));
            return Ok(Exito(r.Apo_Id, r.Apo_Estado, r.Apo_Version));
        }

        [HttpPost]
        [Route("EditarAsync")]
        public async Task<IActionResult> Editar([FromBody] PlanApoyoGuardarDTO obj)
        {
            Answer answer = await _service.Editar(obj);
            if (answer.Access || answer.Data is not PR_tbPlanesApoyo_EscrituraResult r)
                return Ok(Fallo(answer, "No se pudieron guardar los cambios del plan."));
            return Ok(Exito(r.Apo_Id, r.Apo_Estado, r.Apo_Version));
        }

        [HttpPost]
        [Route("CambiarEstadoAsync")]
        public async Task<IActionResult> CambiarEstado([FromBody] PlanApoyoEstadoDTO obj)
        {
            Answer answer = await _service.CambiarEstado(obj);
            if (answer.Access || answer.Data is not PR_tbPlanesApoyo_EscrituraResult r)
                return Ok(Fallo(answer, "No se pudo cambiar el estado del plan."));
            return Ok(Exito(r.Apo_Id, r.Apo_Estado, r.Apo_Version));
        }

        [HttpPost]
        [Route("AgregarPasoAsync")]
        public async Task<IActionResult> AgregarPaso([FromBody] PlanApoyoPasoDTO obj)
        {
            Answer answer = await _service.AgregarPaso(obj);
            if (answer.Access || answer.Data is not PR_tbPlanesApoyoAcciones_EscrituraResult r)
                return Ok(Fallo(answer, "No se pudo agregar el paso."));
            return Ok(Exito(r.Apa_Id));
        }

        [HttpPost]
        [Route("CompletarPasoAsync")]
        public async Task<IActionResult> CompletarPaso([FromBody] PlanApoyoPasoAccionDTO obj)
        {
            Answer answer = await _service.CompletarPaso(obj);
            if (answer.Access || answer.Data is not PR_tbPlanesApoyoAcciones_EscrituraResult r)
                return Ok(Fallo(answer, "No se pudo marcar el paso como hecho."));
            return Ok(Exito(r.Apa_Id));
        }

        [HttpPost]
        [Route("QuitarPasoAsync")]
        public async Task<IActionResult> QuitarPaso([FromBody] PlanApoyoPasoAccionDTO obj)
        {
            Answer answer = await _service.QuitarPaso(obj);
            if (answer.Access || answer.Data is not PR_tbPlanesApoyoAcciones_EscrituraResult r)
                return Ok(Fallo(answer, "No se pudo quitar el paso."));
            return Ok(Exito(r.Apa_Id));
        }

        [HttpPost]
        [Route("AgregarNotaAsync")]
        public async Task<IActionResult> AgregarNota([FromBody] PlanApoyoNotaDTO obj)
        {
            Answer answer = await _service.AgregarNota(obj);
            if (answer.Access || answer.Data is not PR_tbPlanesApoyoNotas_AgregarResult r)
                return Ok(Fallo(answer, "No se pudo agregar la nota."));
            return Ok(Exito(r.Apn_Id));
        }

        [HttpPost]
        [Route("EliminarAsync")]
        public async Task<IActionResult> Eliminar([FromBody] PlanApoyoEliminarDTO obj)
        {
            Answer answer = await _service.Eliminar(obj);
            if (answer.Access || answer.Data is not PR_tbPlanesApoyo_EscrituraResult r)
                return Ok(Fallo(answer, "No se pudo eliminar el plan."));
            return Ok(Exito(r.Apo_Id, r.Apo_Estado));
        }
    }
}
