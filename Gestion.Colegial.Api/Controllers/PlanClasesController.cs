using Gestion.Colegial.Business.Interfaces;
using Gestion.Colegial.Entities;
using Microsoft.AspNetCore.Mvc;
using System.Threading.Tasks;

namespace Gestion.Colegial.Api.Controllers
{
    [ApiController]
    [Route("api/v1/[controller]")]
    public class PlanClasesController : ControllerBase
    {
        private readonly IPlanClasesService _service;
        public PlanClasesController(IPlanClasesService service) { _service = service; }

        [HttpGet("ListAsync")]
        public async Task<IActionResult> List(int Hor_Id)
        {
            Answer answer = await _service.List(Hor_Id);
            return Ok(answer.Data);
        }

        [HttpGet("FindAsync")]
        public async Task<IActionResult> Find(int Pla_Id)
        {
            Answer answer = await _service.Find(Pla_Id);
            return Ok(answer.Data);
        }

        [HttpPost("CreateAsync")]
        public async Task<IActionResult> Create([FromBody] PlanClasesCreateRequest req)
        {
            Answer answer = await _service.Insert(req.Hor_Id, req.Pla_Semana, req.Pla_Tema,
                req.Pla_Objetivos, req.Pla_Recursos, req.UsuarioRegistra);
            return Ok(answer);
        }

        [HttpPut("EditAsync")]
        public async Task<IActionResult> Edit([FromBody] PlanClasesEditRequest req)
        {
            Answer answer = await _service.Update(req.Pla_Id, req.Pla_Semana, req.Pla_Tema,
                req.Pla_Objetivos, req.Pla_Recursos, req.Pla_Estado, req.UsuarioModifica);
            return Ok(answer);
        }

        [HttpPost("DeleteAsync")]
        public async Task<IActionResult> Delete([FromBody] PlanClasesDeleteRequest req)
        {
            Answer answer = await _service.Delete(req.Pla_Id, req.UsuarioModifica);
            return Ok(answer);
        }
    }

    public class PlanClasesDeleteRequest
    {
        public int Pla_Id        { get; set; }
        public int UsuarioModifica { get; set; }
    }

    public class PlanClasesCreateRequest
    {
        public int    Hor_Id          { get; set; }
        public short  Pla_Semana      { get; set; }
        public string Pla_Tema        { get; set; }
        public string Pla_Objetivos   { get; set; }
        public string Pla_Recursos    { get; set; }
        public int    UsuarioRegistra  { get; set; }
    }

    public class PlanClasesEditRequest
    {
        public int    Pla_Id          { get; set; }
        public short  Pla_Semana      { get; set; }
        public string Pla_Tema        { get; set; }
        public string Pla_Objetivos   { get; set; }
        public string Pla_Recursos    { get; set; }
        public string Pla_Estado      { get; set; }
        public int    UsuarioModifica  { get; set; }
    }
}
