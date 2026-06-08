using Gestion.Colegial.Business.Interfaces;
using Gestion.Colegial.Entities;
using Microsoft.AspNetCore.Mvc;
using System.Threading.Tasks;

namespace Gestion.Colegial.Api.Controllers
{
    [ApiController]
    [Route("api/v1/[controller]")]
    public class AlumnosEnRiesgoController : ControllerBase
    {
        private readonly IAlumnosEnRiesgoService _service;
        public AlumnosEnRiesgoController(IAlumnosEnRiesgoService service) { _service = service; }

        [HttpGet("ListAsync")]
        public async Task<IActionResult> List(decimal? PromedioMinimo, int? Anio)
        {
            Answer answer = await _service.List(PromedioMinimo, Anio);
            return Ok(answer.Data);
        }
    }
}
