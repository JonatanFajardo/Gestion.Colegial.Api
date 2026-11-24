using Gestion.Colegial.Business.Interfaces;
using Gestion.Colegial.Entities;
using Microsoft.AspNetCore.Mvc;
using System;
using System.Threading.Tasks;
using Gestion.Colegial.Api.Seguridad;

namespace Gestion.Colegial.Api.Controllers
{
    [ApiController]
    [Route("api/v1/[controller]")]
    [DatoDelServidor(DatoUsuario.Usuario, "UsuarioRegistra", "UsuarioModifica")]
    public class CentroAnunciosController : ControllerBase
    {
        private readonly ICentroAnunciosService _service;
        public CentroAnunciosController(ICentroAnunciosService service) { _service = service; }

        [HttpGet("ListAsync")]
        [RequierePantalla("Centro de anuncios")]
        public async Task<IActionResult> List()
        {
            Answer answer = await _service.List();
            return Ok(answer.Data);
        }

        [HttpPost("CreateAsync")]
        [RequierePantalla("Centro de anuncios")]
        public async Task<IActionResult> Create([FromBody] CentroAnunciosRequest request)
        {
            Answer answer = await _service.Insert(request.Anu_Titulo, request.Anu_Contenido, request.Anu_FechaExpiracion, request.UsuarioRegistra,
                request.Anu_Publico, request.Anu_NivId, request.Anu_CunId, request.Anu_SecId);
            return Ok(answer);
        }

        [HttpGet("OpcionesAsync")]
        [RequierePantalla("Centro de anuncios")]
        public async Task<IActionResult> Opciones(string tipo, int? padre)
        {
            Answer answer = await _service.Opciones(tipo ?? "", padre);
            return Ok(answer.Access || answer.Data is string ? Array.Empty<object>() : answer.Data);
        }

        [HttpPost("DeleteAsync")]
        [RequierePantalla("Centro de anuncios")]
        public async Task<IActionResult> Delete([FromBody] CentroAnunciosDeleteRequest request)
        {
            Answer answer = await _service.Delete(request.Anu_Id, request.UsuarioModifica);
            return Ok(answer);
        }
    }

    public class CentroAnunciosRequest
    {
        public string Anu_Titulo { get; set; }
        public string Anu_Contenido { get; set; }
        public DateTime? Anu_FechaExpiracion { get; set; }
        public int UsuarioRegistra { get; set; }
        public string Anu_Publico { get; set; }
        public int? Anu_NivId { get; set; }
        public int? Anu_CunId { get; set; }
        public int? Anu_SecId { get; set; }
    }

    public class CentroAnunciosDeleteRequest
    {
        public int Anu_Id { get; set; }
        public int UsuarioModifica { get; set; }
    }
}
