using Gestion.Colegial.Business.Interfaces;
using Gestion.Colegial.Entities;
using Microsoft.AspNetCore.Mvc;
using System;
using System.Threading.Tasks;

namespace Gestion.Colegial.Api.Controllers
{
    [ApiController]
    [Route("api/v1/[controller]")]
    public class CentroAnunciosController : ControllerBase
    {
        private readonly ICentroAnunciosService _service;
        public CentroAnunciosController(ICentroAnunciosService service) { _service = service; }

        [HttpGet("ListAsync")]
        public async Task<IActionResult> List()
        {
            Answer answer = await _service.List();
            return Ok(answer.Data);
        }

        [HttpPost("CreateAsync")]
        public async Task<IActionResult> Create([FromBody] CentroAnunciosRequest request)
        {
            Answer answer = await _service.Insert(request.Anu_Titulo, request.Anu_Contenido, request.Anu_FechaExpiracion, request.UsuarioRegistra);
            return Ok(answer);
        }

        [HttpPost("DeleteAsync")]
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
    }

    public class CentroAnunciosDeleteRequest
    {
        public int Anu_Id { get; set; }
        public int UsuarioModifica { get; set; }
    }
}
