using Gestion.Colegial.Business.Interfaces;
using Gestion.Colegial.Entities;
using Microsoft.AspNetCore.Mvc;
using System.Threading.Tasks;

namespace Gestion.Colegial.Api.Controllers
{
    [ApiController]
    [Route("api/v1/[controller]")]
    public class ConfiguracionController : ControllerBase
    {
        private readonly IConfiguracionService _service;
        public ConfiguracionController(IConfiguracionService service) { _service = service; }

        [HttpGet("ListAsync")]
        public async Task<IActionResult> List()
        {
            Answer answer = await _service.List();
            return Ok(answer.Data);
        }

        [HttpPut("UpdateAsync")]
        public async Task<IActionResult> Update([FromBody] ConfiguracionUpdateRequest request)
        {
            Answer answer = await _service.Update(request.Con_Id, request.Con_Valor, request.UsuarioModifica);
            return Ok(answer);
        }
    }

    public class ConfiguracionUpdateRequest
    {
        public int Con_Id { get; set; }
        public string Con_Valor { get; set; }
        public int UsuarioModifica { get; set; }
    }
}
