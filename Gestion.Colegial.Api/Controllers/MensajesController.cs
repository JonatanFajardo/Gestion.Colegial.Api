using Gestion.Colegial.Business.Interfaces;
using Gestion.Colegial.Entities;
using Microsoft.AspNetCore.Mvc;
using System.Threading.Tasks;

namespace Gestion.Colegial.Api.Controllers
{
    [ApiController]
    [Route("api/v1/[controller]")]
    public class MensajesController : ControllerBase
    {
        private readonly IMensajesService _service;
        public MensajesController(IMensajesService service) { _service = service; }

        [HttpGet("ListAsync")]
        public async Task<IActionResult> List(int? Alu_Id, int? UsuarioId)
        {
            Answer answer = await _service.List(Alu_Id, UsuarioId);
            return Ok(answer.Data);
        }

        [HttpPost("CreateAsync")]
        public async Task<IActionResult> Create([FromBody] MensajesRequest request)
        {
            Answer answer = await _service.Insert(request.Msg_Asunto, request.Msg_Contenido, request.Alu_Id, request.UsuarioEnvia);
            return Ok(answer);
        }

        [HttpPost("DeleteAsync")]
        public async Task<IActionResult> Delete([FromBody] MensajesDeleteRequest request)
        {
            Answer answer = await _service.Delete(request.Msg_Id, request.UsuarioModifica);
            return Ok(answer);
        }
    }

    public class MensajesRequest
    {
        public string Msg_Asunto    { get; set; }
        public string Msg_Contenido { get; set; }
        public int    Alu_Id        { get; set; }
        public int    UsuarioEnvia  { get; set; }
    }

    public class MensajesDeleteRequest
    {
        public int Msg_Id          { get; set; }
        public int UsuarioModifica { get; set; }
    }
}
