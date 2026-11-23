using Gestion.Colegial.Business.Interfaces;
using Gestion.Colegial.Entities;
using Microsoft.AspNetCore.Mvc;
using Gestion.Colegial.Entities.Entities;
using System;
using System.Linq;
using System.Threading.Tasks;
using Gestion.Colegial.Api.Seguridad;

namespace Gestion.Colegial.Api.Controllers
{
    [ApiController]
    [Route("api/v1/[controller]")]
    [DatoDelServidor(DatoUsuario.Usuario, "UsuarioRegistra", "UsuarioModifica")]
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

        /// <summary>Horarios que ve el usuario para pasar lista en una fecha (dirección: todos; docente: los suyos y los que cubre).</summary>
        [HttpGet("HorariosAsync")]
        public async Task<IActionResult> Horarios(int Usu_Id, DateTime Fecha, int? Niv_Id, int? Cun_Id, int? Sec_Id)
        {
            Answer answer = await _service.Horarios(Usu_Id, Fecha, Niv_Id, Cun_Id, Sec_Id);
            return Ok(answer.Data);
        }

        /// <summary>¿Puede este usuario pasar lista de este horario en esta fecha?</summary>
        [HttpGet("PuedeAsync")]
        public async Task<IActionResult> Puede(int Usu_Id, int Hor_Id, DateTime Fecha)
        {
            Answer answer = await _service.Puede(Usu_Id, Hor_Id, Fecha);
            var fila = (answer.Data as System.Collections.IEnumerable)?.Cast<PR_Asistencia_PuedeResult>().FirstOrDefault();
            return Ok(new { Puede = fila != null && fila.Puede });
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
            // El ADM solo mira el código HTTP: un error de la base (p. ej. día cerrado por el calendario)
            // debe llegar como error, no como 200 con Access = true.
            if (answer.Access) return BadRequest(new { Mensaje = "No se pudo guardar la asistencia." });
            return Ok(answer);
        }

        [HttpPut("EditAsync")]
        public async Task<IActionResult> Edit([FromBody] AsistenciaEditRequest request)
        {
            Answer answer = await _service.Update(request.Asi_Id, request.Asi_Estado, request.Asi_Observacion, request.UsuarioModifica);
            // El ADM solo mira el código HTTP: un error de la base (p. ej. día cerrado por el calendario)
            // debe llegar como error, no como 200 con Access = true.
            if (answer.Access) return BadRequest(new { Mensaje = "No se pudo guardar la asistencia." });
            return Ok(answer);
        }
    }

    public class AsistenciaRequest
    {
        public int Hor_Id { get; set; }
        public int Alu_Id { get; set; }
        public DateTime Asi_Fecha { get; set; }
        public string Asi_Estado { get; set; }
        public string? Asi_Observacion { get; set; }
        public int UsuarioRegistra { get; set; }
    }

    public class AsistenciaEditRequest
    {
        public int Asi_Id { get; set; }
        public string Asi_Estado { get; set; }
        public string? Asi_Observacion { get; set; }
        public int UsuarioModifica { get; set; }
    }
}
