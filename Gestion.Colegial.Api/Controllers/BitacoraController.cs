using Gestion.Colegial.Business.Interfaces;
using Gestion.Colegial.Entities;
using Microsoft.AspNetCore.Mvc;
using System.Threading.Tasks;

namespace Gestion.Colegial.Api.Controllers
{
    [ApiController]
    [Route("api/v1/[controller]")]
    public class BitacoraController : ControllerBase
    {
        private readonly IBitacoraService _service;
        public BitacoraController(IBitacoraService service) { _service = service; }

        [HttpGet("ListAsync")]
        public async Task<IActionResult> List(int? Usu_Id, string Bit_Tabla, int? Top)
        {
            Answer answer = await _service.List(Usu_Id, Bit_Tabla, Top);
            return Ok(answer.Data);
        }

        [HttpPost("CreateAsync")]
        public async Task<IActionResult> Create([FromBody] BitacoraRequest request)
        {
            Answer answer = await _service.Insert(request.Usu_Id, request.Bit_Accion, request.Bit_Tabla, request.Bit_RegistroId, request.Bit_Descripcion, request.Bit_Ip);
            return Ok(answer);
        }
    }

    public class BitacoraRequest
    {
        public int Usu_Id { get; set; }
        public string Bit_Accion { get; set; }
        public string Bit_Tabla { get; set; }
        public int? Bit_RegistroId { get; set; }
        public string Bit_Descripcion { get; set; }
        public string Bit_Ip { get; set; }
    }
}
