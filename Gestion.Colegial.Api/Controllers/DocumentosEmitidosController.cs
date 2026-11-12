using Gestion.Colegial.Business.Interfaces;
using Gestion.Colegial.Entities;
using Gestion.Colegial.Entities.DTOs;
using Microsoft.AspNetCore.Mvc;

namespace Gestion.Colegial.Api.Controllers
{
    /// <summary>
    /// Constancias y expediente: documentos oficiales congelados de un alumno (ESTUDIO, BOLETIN,
    /// EXPEDIENTE). No hay editar ni borrar: para corregir se emite una revisión nueva.
    /// EmitirAsync responde un entero: Id nuevo (mayor que 0) o código (-1 sin notas, -2 sin
    /// matrícula, -3 datos inválidos, -4 revisión sin motivo, 0 error inesperado).
    /// </summary>
    [ApiController]
    [Route("api/v1/[controller]")]
    public class DocumentosEmitidosController : ControllerBase
    {
        private readonly IDocumentosEmitidosService _service;

        public DocumentosEmitidosController(IDocumentosEmitidosService service)
        {
            _service = service;
        }

        /// <summary>Listado (más reciente primero). Filtros opcionales.</summary>
        [HttpGet]
        [Route("ListAsync")]
        public async Task<IActionResult> List(string? tipo = null, int? aluId = null, int? aniId = null)
        {
            Answer answer = await _service.List(tipo, aluId, aniId);
            return Ok(answer.Data);
        }

        /// <summary>Un documento con su contenido. value = Doc_Id; respuesta vacía si no existe.</summary>
        [HttpGet]
        [Route("FindAsync")]
        public async Task<IActionResult> Find(int value)
        {
            Answer answer = await _service.Find(value);
            return Ok(answer.Data);
        }

        /// <summary>El documento tal como quedaría, sin guardarlo.</summary>
        [HttpGet]
        [Route("VistaPreviaAsync")]
        public async Task<IActionResult> VistaPrevia(string? tipo, int aluId, int? aniId = null, int? pacId = null)
        {
            Answer answer = await _service.VistaPrevia(tipo, aluId, aniId, pacId);
            return Ok(answer.Data);
        }

        [HttpPost]
        [Route("EmitirAsync")]
        public async Task<IActionResult> Emitir([FromBody] DocumentoEmitirDTO obj)
        {
            Answer answer = await _service.Emitir(obj);
            return Ok(answer.Data);
        }
    }
}
