using Gestion.Colegial.Business.Interfaces;
using Gestion.Colegial.Entities;
using Microsoft.AspNetCore.Mvc;
using System;
using System.Threading.Tasks;

namespace Gestion.Colegial.Api.Controllers
{
    [ApiController]
    [Route("api/v1/[controller]")]
    public class CumplimientoDocumentosController : ControllerBase
    {
        private readonly ICumplimientoDocumentosService _service;
        public CumplimientoDocumentosController(ICumplimientoDocumentosService service) { _service = service; }

        [HttpGet("ListAsync")]
        public async Task<IActionResult> List(int? Emp_Id)
        {
            Answer answer = await _service.List(Emp_Id);
            return Ok(answer.Data);
        }

        [HttpPut("MarcarEntregadoAsync")]
        public async Task<IActionResult> MarcarEntregado([FromBody] CumplimientoDocumentosRequest request)
        {
            Answer answer = await _service.MarcarEntregado(request.Emp_Id, request.Documento, request.EsEntregado, request.FechaEntrega, request.Doc_FechaVencimiento, request.Observacion, request.UsuarioRegistra);
            return Ok(answer);
        }
    }

    public class CumplimientoDocumentosRequest
    {
        public int Emp_Id { get; set; }
        public string Documento { get; set; }
        public bool EsEntregado { get; set; }
        public DateTime? FechaEntrega { get; set; }
        public DateTime? Doc_FechaVencimiento { get; set; }
        public string Observacion { get; set; }
        public int UsuarioRegistra { get; set; }
    }
}
