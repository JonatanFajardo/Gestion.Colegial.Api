using Gestion.Colegial.Business.Interfaces;
using Gestion.Colegial.Entities;
using Microsoft.AspNetCore.Mvc;
using System.Threading.Tasks;

namespace Gestion.Colegial.Api.Controllers
{
    [ApiController]
    [Route("api/v1/[controller]")]
    public class NotificacionesController : ControllerBase
    {
        private readonly INotificacionService _service;

        public NotificacionesController(INotificacionService service)
        {
            _service = service;
        }

        [HttpGet("ListAsync")]
        public async Task<IActionResult> List(int usuId, bool soloNoLeidas = false)
        {
            Answer answer = await _service.ListByUsuario(usuId, soloNoLeidas);
            return Ok(answer.Data);
        }

        [HttpPut("MarcarLeidaAsync")]
        public async Task<IActionResult> MarcarLeida(int notId)
        {
            Answer answer = await _service.MarcarLeida(notId);
            return Ok(answer.Data);
        }

        [HttpPost("CreateAsync")]
        public async Task<IActionResult> Create([FromBody] NotificacionRequest request)
        {
            Answer answer = await _service.Insert(
                request.Usu_Id, request.Not_Titulo, request.Not_Mensaje,
                request.Not_Tipo, request.Not_UrlDestino, request.Usu_UsuarioRegistra
            );
            return Ok(answer.Data);
        }
    }

    public class NotificacionRequest
    {
        public int Usu_Id { get; set; }
        public string Not_Titulo { get; set; }
        public string Not_Mensaje { get; set; }
        public string Not_Tipo { get; set; } = "I";
        public string Not_UrlDestino { get; set; }
        public int Usu_UsuarioRegistra { get; set; }
    }
}
