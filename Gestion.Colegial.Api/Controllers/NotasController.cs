using Gestion.Colegial.Business.Interfaces;
using Gestion.Colegial.Entities;
using Microsoft.AspNetCore.Mvc;
using System;
using System.Threading.Tasks;

namespace Gestion.Colegial.Api.Controllers
{
    [ApiController]
    [Route("api/v1/[controller]")]
    public class NotasController : ControllerBase
    {
        private readonly INotasService _service;
        public NotasController(INotasService service) { _service = service; }

        [HttpGet("ListAsync")]
        public async Task<IActionResult> List(int Hor_Id, int Par_Id)
        {
            Answer answer = await _service.List(Hor_Id, Par_Id);
            return Ok(answer.Data);
        }

        [HttpGet("CuadernoAsync")]
        public async Task<IActionResult> Cuaderno(int Sec_Id, int Mat_Id, int Par_Id, int Sem_Id, int Anio)
        {
            Answer answer = await _service.Cuaderno(Sec_Id, Mat_Id, Par_Id, Sem_Id, Anio);
            return Ok(answer.Data);
        }

        [HttpGet("BoletinAsync")]
        public async Task<IActionResult> Boletin(int Alu_Id, int Sem_Id, int Anio)
        {
            Answer answer = await _service.Boletin(Alu_Id, Sem_Id, Anio);
            return Ok(answer.Data);
        }

        [HttpPost("CreateAsync")]
        public async Task<IActionResult> Create([FromBody] NotaCreateRequest request)
        {
            Answer answer = await _service.Insert(
                request.Alu_Id, request.Sec_Id, request.Mat_Id, request.Sem_Id, request.Par_Id,
                request.Not_Nota, request.Not_Año, request.UsuarioRegistra);
            return Ok(answer);
        }

        [HttpPut("EditAsync")]
        public async Task<IActionResult> Edit([FromBody] NotaEditRequest request)
        {
            Answer answer = await _service.Edit(request.Not_Id, request.Not_Nota, request.UsuarioModifica);
            return Ok(answer);
        }
    }

    public class NotaCreateRequest
    {
        public int Alu_Id { get; set; }
        public int Sec_Id { get; set; }
        public int Mat_Id { get; set; }
        public int Sem_Id { get; set; }
        public int Par_Id { get; set; }
        public decimal Not_Nota { get; set; }
        public DateTime Not_Año { get; set; }
        public int UsuarioRegistra { get; set; }
    }

    public class NotaEditRequest
    {
        public int Not_Id { get; set; }
        public decimal Not_Nota { get; set; }
        public int UsuarioModifica { get; set; }
    }
}
