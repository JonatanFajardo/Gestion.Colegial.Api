using Gestion.Colegial.Business.Interfaces;
using Gestion.Colegial.Entities;
using Microsoft.AspNetCore.Mvc;
using System.Threading.Tasks;

namespace Gestion.Colegial.Api.Controllers
{
    [ApiController]
    [Route("api/v1/[controller]")]
    public class FlujoCajaController : ControllerBase
    {
        private readonly IFlujoCajaService _service;
        public FlujoCajaController(IFlujoCajaService service) { _service = service; }

        [HttpGet("ListAsync")]
        public async Task<IActionResult> List(int Anio)
        {
            Answer answer = await _service.List(Anio);
            return Ok(answer.Data);
        }
    }
}
