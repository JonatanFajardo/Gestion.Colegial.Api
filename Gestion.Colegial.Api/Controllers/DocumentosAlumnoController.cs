using Gestion.Colegial.Business.Interfaces;
using Gestion.Colegial.Entities;
using Microsoft.AspNetCore.Mvc;
using System;
using System.Threading.Tasks;

namespace Gestion.Colegial.Api.Controllers
{
    [ApiController]
    [Route("api/v1/[controller]")]
    public class DocumentosAlumnoController : ControllerBase
    {
        private readonly IDocumentosAlumnoService _service;
        public DocumentosAlumnoController(IDocumentosAlumnoService service) { _service = service; }

        [HttpGet("ListAsync")]
        public async Task<IActionResult> List(int Alu_Id)
        {
            Answer answer = await _service.List(Alu_Id);
            return Ok(answer.Data);
        }

        [HttpGet("PendientesAsync")]
        public async Task<IActionResult> PendientesList()
        {
            Answer answer = await _service.PendientesList();
            return Ok(answer.Data);
        }

        [HttpPut("UpdateAsync")]
        public async Task<IActionResult> Update([FromBody] DocumentosAlumnoRequest request)
        {
            Answer answer = await _service.Update(request.Alu_Id, request.TDoc_Id, request.Doa_EsEntregado, request.Doa_FechaEntrega, request.Doa_Observacion, request.UsuarioRegistra);
            return Ok(answer);
        }
    }

    public class DocumentosAlumnoRequest
    {
        public int Alu_Id { get; set; }
        public int TDoc_Id { get; set; }
        public bool Doa_EsEntregado { get; set; }
        public DateTime? Doa_FechaEntrega { get; set; }
        public string Doa_Observacion { get; set; }
        public int UsuarioRegistra { get; set; }
    }
}
