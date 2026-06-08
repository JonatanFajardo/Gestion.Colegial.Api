using Gestion.Colegial.Business.Interfaces;
using Gestion.Colegial.Entities;
using Microsoft.AspNetCore.Mvc;
using System;
using System.Threading.Tasks;

namespace Gestion.Colegial.Api.Controllers
{
    [ApiController]
    [Route("api/v1/[controller]")]
    public class ArqueosCajaController : ControllerBase
    {
        private readonly IArqueosCajaService _service;
        public ArqueosCajaController(IArqueosCajaService service) { _service = service; }

        [HttpGet("FindAsync")]
        public async Task<IActionResult> Find(int Arq_Id)
        {
            Answer answer = await _service.Find(Arq_Id);
            return Ok(answer.Data);
        }

        [HttpGet("LastByUsuarioAsync")]
        public async Task<IActionResult> LastByUsuario(int Usu_Id)
        {
            Answer answer = await _service.LastByUsuario(Usu_Id);
            return Ok(answer.Data);
        }

        [HttpPost("CreateAsync")]
        public async Task<IActionResult> Create([FromBody] ArqueoCajaRequest request)
        {
            Answer answer = await _service.Insert(request.Usu_Id, request.Arq_Fecha, request.Arq_TotalEfectivo, request.Arq_TotalTransferencia, request.Arq_TotalTarjeta, request.Arq_Observaciones, request.UsuarioRegistra);
            return Ok(answer);
        }
    }

    public class ArqueoCajaRequest
    {
        public int Usu_Id { get; set; }
        public DateTime Arq_Fecha { get; set; }
        public decimal Arq_TotalEfectivo { get; set; }
        public decimal Arq_TotalTransferencia { get; set; }
        public decimal Arq_TotalTarjeta { get; set; }
        public string Arq_Observaciones { get; set; }
        public int UsuarioRegistra { get; set; }
    }
}
