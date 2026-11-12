using Gestion.Colegial.Business.Interfaces;
using Gestion.Colegial.Entities;
using Microsoft.AspNetCore.Mvc;
using System;
using System.Threading.Tasks;

namespace Gestion.Colegial.Api.Controllers
{
    [ApiController]
    [Route("api/v1/[controller]")]
    public class TareasController : ControllerBase
    {
        private readonly ITareasService _service;
        public TareasController(ITareasService service) { _service = service; }

        [HttpGet("ListAsync")]
        public async Task<IActionResult> List(int Hor_Id)
        {
            Answer answer = await _service.List(Hor_Id);
            return Ok(answer.Data);
        }

        [HttpGet("FindAsync")]
        public async Task<IActionResult> Find(int Tar_Id)
        {
            Answer answer = await _service.Find(Tar_Id);
            return Ok(answer.Data);
        }

        [HttpPost("CreateAsync")]
        public async Task<IActionResult> Create([FromBody] TareaCreateRequest req)
        {
            Answer answer = await _service.Insert(req.Hor_Id, req.Tar_Titulo, req.Tar_Descripcion,
                req.Tar_FechaEntrega, req.Tar_Punteo, req.UsuarioRegistra);
            return Ok(answer);
        }

        [HttpPut("EditAsync")]
        public async Task<IActionResult> Edit([FromBody] TareaEditRequest req)
        {
            Answer answer = await _service.Update(req.Tar_Id, req.Tar_Titulo, req.Tar_Descripcion,
                req.Tar_FechaEntrega, req.Tar_Punteo, req.Tar_Estado, req.UsuarioModifica);
            return Ok(answer);
        }

        [HttpPost("DeleteAsync")]
        public async Task<IActionResult> Delete([FromBody] TareaDeleteRequest req)
        {
            Answer answer = await _service.Delete(req.Tar_Id, req.UsuarioModifica);
            return Ok(answer);
        }
    }

    public class TareaDeleteRequest
    {
        public int Tar_Id        { get; set; }
        public int UsuarioModifica { get; set; }
    }

    public class TareaCreateRequest
    {
        public int      Hor_Id           { get; set; }
        public string   Tar_Titulo       { get; set; }
        public string   Tar_Descripcion  { get; set; }
        public DateTime Tar_FechaEntrega { get; set; }
        public decimal  Tar_Punteo       { get; set; }
        public int      UsuarioRegistra  { get; set; }
    }

    public class TareaEditRequest
    {
        public int      Tar_Id           { get; set; }
        public string   Tar_Titulo       { get; set; }
        public string   Tar_Descripcion  { get; set; }
        public DateTime Tar_FechaEntrega { get; set; }
        public decimal  Tar_Punteo       { get; set; }
        public string   Tar_Estado       { get; set; }
        public int      UsuarioModifica  { get; set; }
    }
}
