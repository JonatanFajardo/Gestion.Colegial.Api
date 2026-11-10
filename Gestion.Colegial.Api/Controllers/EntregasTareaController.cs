using Gestion.Colegial.Business.Interfaces;
using Gestion.Colegial.Entities;
using Microsoft.AspNetCore.Mvc;
using System.Threading.Tasks;

namespace Gestion.Colegial.Api.Controllers
{
    [ApiController]
    [Route("api/v1/[controller]")]
    public class EntregasTareaController : ControllerBase
    {
        private readonly IEntregasTareaService _service;
        public EntregasTareaController(IEntregasTareaService service) { _service = service; }

        [HttpGet("ListAsync")]
        public async Task<IActionResult> List(int Tar_Id)
        {
            Answer answer = await _service.List(Tar_Id);
            return Ok(answer.Data);
        }

        [HttpPost("UpsertAsync")]
        public async Task<IActionResult> Upsert([FromBody] EntregaTareaUpsertRequest req)
        {
            Answer answer = await _service.Upsert(req.Tar_Id, req.Alu_Id, req.Ent_Entregado, req.Ent_Observacion, req.UsuarioRegistra);
            return Ok(answer);
        }

        [HttpPut("CalificarAsync")]
        public async Task<IActionResult> Calificar([FromBody] EntregaTareaCalificarRequest req)
        {
            Answer answer = await _service.Update(req.Ent_Id, req.Ent_Nota, req.Ent_Observacion, req.UsuarioModifica);
            return Ok(answer);
        }
    }

    public class EntregaTareaUpsertRequest
    {
        public int    Tar_Id          { get; set; }
        public int    Alu_Id          { get; set; }
        public bool   Ent_Entregado   { get; set; }
        public string Ent_Observacion { get; set; }
        public int    UsuarioRegistra { get; set; }
    }

    public class EntregaTareaCalificarRequest
    {
        public int     Ent_Id          { get; set; }
        public decimal Ent_Nota        { get; set; }
        public string  Ent_Observacion { get; set; }
        public int     UsuarioModifica { get; set; }
    }
}
