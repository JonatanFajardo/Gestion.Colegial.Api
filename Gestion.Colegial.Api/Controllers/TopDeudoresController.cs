using Gestion.Colegial.Business.Interfaces;
using Gestion.Colegial.Entities;
using Microsoft.AspNetCore.Mvc;
using System.Threading.Tasks;

namespace Gestion.Colegial.Api.Controllers
{
    [ApiController]
    [Route("api/v1/[controller]")]
    public class TopDeudoresController : ControllerBase
    {
        private readonly ITopDeudoresService _service;
        public TopDeudoresController(ITopDeudoresService service) { _service = service; }

        [HttpGet("ListAsync")]
        public async Task<IActionResult> List(int? Top, int? Anio)
        {
            Answer answer = await _service.List(Top, Anio);
            return Ok(answer.Data);
        }
    }
}
