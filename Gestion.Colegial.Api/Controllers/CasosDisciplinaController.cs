using Gestion.Colegial.Business.Interfaces;
using Gestion.Colegial.Entities;
using Gestion.Colegial.Entities.DTOs;
using Gestion.Colegial.Entities.Entities;
using Microsoft.AspNetCore.Mvc;

namespace Gestion.Colegial.Api.Controllers
{
    /// <summary>
    /// Disciplina (espejo de Skuul "Cases"): casos de conducta y de protección del menor.
    /// Un caso de protección es reservado: solo lo leen quien tiene el permiso de reservados
    /// (verReservados), quien lo reportó (usuId) y quien lo atiende (empId).
    /// Las escrituras siempre responden { Ok, Id, Referencia, Estado, Mensaje }.
    /// </summary>
    [ApiController]
    [Route("api/v1/[controller]")]
    public class CasosDisciplinaController : ControllerBase
    {
        private readonly ICasosDisciplinaService _service;

        public CasosDisciplinaController(ICasosDisciplinaService service)
        {
            _service = service;
        }

        private static object Fallo(Answer answer, string general) =>
            new { Ok = false, Id = 0, Referencia = (string?)null, Estado = (string?)null, Mensaje = answer.Message ?? general };

        /// <summary>Listado, 20 por página (más reciente primero). Cada fila trae TotalFilas.</summary>
        [HttpGet]
        [Route("ListAsync")]
        public async Task<IActionResult> List(string? estado, string? tipo, bool soloAbiertos = false, bool verReservados = false,
                                              int? usuId = null, int? empId = null, int pagina = 1)
        {
            Answer answer = await _service.List(estado, tipo, soloAbiertos, verReservados, usuId, empId, pagina);
            return Ok(answer.Data);
        }

        [HttpGet]
        [Route("AbiertosAsync")]
        public async Task<IActionResult> Abiertos(bool verReservados = false, int? usuId = null, int? empId = null)
        {
            Answer answer = await _service.Abiertos(verReservados, usuId, empId);
            return Ok(answer.Data);
        }

        /// <summary>Un caso; respuesta vacía si no existe o la persona no lo puede leer.</summary>
        [HttpGet]
        [Route("FindAsync")]
        public async Task<IActionResult> Find(int value, bool verReservados = false, int? usuId = null, int? empId = null)
        {
            Answer answer = await _service.Find(value, verReservados, usuId, empId);
            return Ok(answer.Data);
        }

        [HttpGet]
        [Route("PersonasAsync")]
        public async Task<IActionResult> Personas(int value) => Ok((await _service.Personas(value)).Data);

        [HttpGet]
        [Route("AccionesAsync")]
        public async Task<IActionResult> Acciones(int value) => Ok((await _service.Acciones(value)).Data);

        [HttpGet]
        [Route("EstadosAsync")]
        public async Task<IActionResult> Estados(int value) => Ok((await _service.Estados(value)).Data);

        /// <summary>Notas; las privadas solo para quienes atienden el caso.</summary>
        [HttpGet]
        [Route("NotasAsync")]
        public async Task<IActionResult> Notas(int value, bool verReservados = false, int? usuId = null, int? empId = null) =>
            Ok((await _service.Notas(value, verReservados, usuId, empId)).Data);

        [HttpGet]
        [Route("AlumnosAsync")]
        public async Task<IActionResult> Alumnos() => Ok((await _service.Alumnos()).Data);

        [HttpGet]
        [Route("EmpleadosAsync")]
        public async Task<IActionResult> Empleados() => Ok((await _service.Empleados()).Data);

        [HttpPost]
        [Route("RegistrarAsync")]
        public async Task<IActionResult> Registrar([FromBody] CasoDisciplinaRegistrarDTO obj)
        {
            Answer answer = await _service.Registrar(obj);
            if (answer.Access || answer.Data is not PR_tbCasosDisciplina_RegistrarResult r)
                return Ok(Fallo(answer, "No se pudo registrar el caso."));
            return Ok(new { Ok = true, Id = r.Cas_Id, Referencia = r.Cas_Referencia, Estado = "reportado", Mensaje = (string?)null });
        }

        [HttpPost]
        [Route("CambiarEstadoAsync")]
        public async Task<IActionResult> CambiarEstado([FromBody] CasoDisciplinaEstadoDTO obj)
        {
            Answer answer = await _service.CambiarEstado(obj);
            if (answer.Access || answer.Data is not PR_tbCasosDisciplina_CambiarEstadoResult r)
                return Ok(Fallo(answer, "No se pudo mover el caso."));
            return Ok(new { Ok = true, Id = r.Cas_Id, Referencia = (string?)null, Estado = r.Cas_Estado, Mensaje = (string?)null });
        }

        [HttpPost]
        [Route("AgregarAccionAsync")]
        public async Task<IActionResult> AgregarAccion([FromBody] CasoDisciplinaAccionDTO obj)
        {
            Answer answer = await _service.AgregarAccion(obj);
            if (answer.Access || answer.Data is not PR_tbCasosDisciplinaAcciones_AgregarResult r)
                return Ok(Fallo(answer, "No se pudo agregar la acción."));
            return Ok(new { Ok = true, Id = r.Cac_Id, Referencia = (string?)null, Estado = (string?)null, Mensaje = (string?)null });
        }

        [HttpPost]
        [Route("CompletarAccionAsync")]
        public async Task<IActionResult> CompletarAccion(int casId, int cacId, int? usuario = null)
        {
            Answer answer = await _service.CompletarAccion(casId, cacId, usuario);
            if (answer.Access || answer.Data is not PR_tbCasosDisciplinaAcciones_AgregarResult r)
                return Ok(Fallo(answer, "No se pudo marcar la acción como hecha."));
            return Ok(new { Ok = true, Id = r.Cac_Id, Referencia = (string?)null, Estado = (string?)null, Mensaje = (string?)null });
        }

        [HttpPost]
        [Route("AgregarNotaAsync")]
        public async Task<IActionResult> AgregarNota([FromBody] CasoDisciplinaNotaDTO obj)
        {
            Answer answer = await _service.AgregarNota(obj);
            if (answer.Access || answer.Data is not PR_tbCasosDisciplinaNotas_AgregarResult r)
                return Ok(Fallo(answer, "No se pudo agregar la nota."));
            return Ok(new { Ok = true, Id = r.Cno_Id, Referencia = (string?)null, Estado = (string?)null, Mensaje = (string?)null });
        }
    }
}
