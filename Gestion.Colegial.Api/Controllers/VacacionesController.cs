using Gestion.Colegial.Business.Interfaces;
using Gestion.Colegial.Entities;
using Microsoft.AspNetCore.Mvc;
using System;
using System.Threading.Tasks;

namespace Gestion.Colegial.Api.Controllers
{
    [ApiController]
    [Route("api/v1/[controller]")]
    public class VacacionesController : ControllerBase
    {
        private readonly IVacacionesService _service;
        public VacacionesController(IVacacionesService service) { _service = service; }

        [HttpGet("ListAsync")]
        public async Task<IActionResult> List(int? Emp_Id)
        {
            Answer answer = await _service.List(Emp_Id);
            return Ok(answer.Data);
        }

        [HttpPost("CreateAsync")]
        public async Task<IActionResult> Create([FromBody] VacacionesRequest request)
        {
            Answer answer = await _service.Insert(request.Emp_Id, request.Vac_Tipo, request.Vac_FechaInicio, request.Vac_FechaFin, request.Vac_Motivo, request.UsuarioRegistra);
            return Ok(answer);
        }

        [HttpPut("ApproveAsync")]
        public async Task<IActionResult> Approve([FromBody] VacacionesApproveRequest request)
        {
            Answer answer = await _service.Approve(request.Vac_Id, request.Vac_Estado, request.UsuarioModifica);
            return Ok(answer);
        }

        [HttpPut("RemoveAsync")]
        public async Task<IActionResult> Remove(int Vac_Id, int usuarioModifica)
        {
            Answer answer = await _service.Delete(Vac_Id, usuarioModifica);
            return Ok(answer);
        }
    }

    public class VacacionesRequest
    {
        public int Emp_Id { get; set; }
        public string Vac_Tipo { get; set; }
        public DateTime Vac_FechaInicio { get; set; }
        public DateTime Vac_FechaFin { get; set; }
        public string Vac_Motivo { get; set; }
        public int UsuarioRegistra { get; set; }
    }

    public class VacacionesApproveRequest
    {
        public int Vac_Id { get; set; }
        public string Vac_Estado { get; set; }
        public int UsuarioModifica { get; set; }
    }
}
