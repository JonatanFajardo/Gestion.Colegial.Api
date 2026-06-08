using Gestion.Colegial.Business.Interfaces;
using Gestion.Colegial.Entities;
using Microsoft.AspNetCore.Mvc;
using System;
using System.Threading.Tasks;

namespace Gestion.Colegial.Api.Controllers
{
    [ApiController]
    [Route("api/v1/[controller]")]
    public class AsistenciaController : ControllerBase
    {
        private readonly IAsistenciaService _service;
        public AsistenciaController(IAsistenciaService service) { _service = service; }

        [HttpGet("ListAsync")]
        public async Task<IActionResult> List(int Hor_Id, DateTime Fecha)
        {
            Answer answer = await _service.List(Hor_Id, Fecha);
            return Ok(answer.Data);
        }

        [HttpGet("ByAlumnoAsync")]
        public async Task<IActionResult> ByAlumno(int Alu_Id, int? Anio)
        {
            Answer answer = await _service.ByAlumno(Alu_Id, Anio);
            return Ok(answer.Data);
        }

        [HttpPost("CreateAsync")]
        public async Task<IActionResult> Create([FromBody] AsistenciaRequest request)
        {
            Answer answer = await _service.Insert(request.Hor_Id, request.Alu_Id, request.Asi_Fecha, request.Asi_Estado, request.Asi_Observacion, request.UsuarioRegistra);
            return Ok(answer);
        }

        [HttpPut("EditAsync")]
        public async Task<IActionResult> Edit([FromBody] AsistenciaEditRequest request)
        {
            Answer answer = await _service.Update(request.Asi_Id, request.Asi_Estado, request.Asi_Observacion, request.UsuarioModifica);
            return Ok(answer);
        }
    }

    public class AsistenciaRequest
    {
        public int Hor_Id { get; set; }
        public int Alu_Id { get; set; }
        public DateTime Asi_Fecha { get; set; }
        public string Asi_Estado { get; set; }
        public string Asi_Observacion { get; set; }
        public int UsuarioRegistra { get; set; }
    }

    public class AsistenciaEditRequest
    {
        public int Asi_Id { get; set; }
        public string Asi_Estado { get; set; }
        public string Asi_Observacion { get; set; }
        public int UsuarioModifica { get; set; }
    }
}
