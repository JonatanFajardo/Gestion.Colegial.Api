using Gestion.Colegial.Business.Interfaces;
using Gestion.Colegial.Entities;
using Microsoft.AspNetCore.Mvc;
using System;
using System.Threading.Tasks;

namespace Gestion.Colegial.Api.Controllers
{
    [ApiController]
    [Route("api/v1/[controller]")]
    public class AsistenciaEmpleadosController : ControllerBase
    {
        private readonly IAsistenciaEmpleadosService _service;
        public AsistenciaEmpleadosController(IAsistenciaEmpleadosService service) { _service = service; }

        [HttpGet("ListAsync")]
        public async Task<IActionResult> List(int? Emp_Id, DateTime? Fecha)
        {
            Answer answer = await _service.List(Emp_Id, Fecha);
            return Ok(answer.Data);
        }

        [HttpPost("CreateAsync")]
        public async Task<IActionResult> Create([FromBody] AsistenciaEmpleadosRequest request)
        {
            Answer answer = await _service.Insert(
                request.Emp_Id, request.AsiEmp_Fecha, request.AsiEmp_Estado,
                request.AsiEmp_Observacion, request.UsuarioRegistra);
            return Ok(answer);
        }
    }

    public class AsistenciaEmpleadosRequest
    {
        public int Emp_Id { get; set; }
        public DateTime AsiEmp_Fecha { get; set; }
        public string AsiEmp_Estado { get; set; }
        public string AsiEmp_Observacion { get; set; }
        public int UsuarioRegistra { get; set; }
    }
}
