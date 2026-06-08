using Gestion.Colegial.Business.Interfaces;
using Gestion.Colegial.Entities;
using Microsoft.AspNetCore.Mvc;
using System.Threading.Tasks;

namespace Gestion.Colegial.Api.Controllers
{
    [ApiController]
    [Route("api/v1/[controller]")]
    public class MapaAulasController : ControllerBase
    {
        private readonly IMapaAulasService _service;
        public MapaAulasController(IMapaAulasService service) { _service = service; }

        [HttpGet("ListAsync")]
        public async Task<IActionResult> List()
        {
            Answer answer = await _service.GetMapa();
            return Ok(answer.Data);
        }
    }
}
