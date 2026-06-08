using Gestion.Colegial.Business.Interfaces;
using Gestion.Colegial.Entities;
using Microsoft.AspNetCore.Mvc;
using System.Threading.Tasks;

namespace Gestion.Colegial.Api.Controllers
{
    [ApiController]
    [Route("api/v1/[controller]")]
    public class MorosidadPorNivelController : ControllerBase
    {
        private readonly IMorosidadPorNivelService _service;
        public MorosidadPorNivelController(IMorosidadPorNivelService service) { _service = service; }

        [HttpGet("ListAsync")]
        public async Task<IActionResult> List(int? Anio)
        {
            Answer answer = await _service.List(Anio);
            return Ok(answer.Data);
        }
    }
}
