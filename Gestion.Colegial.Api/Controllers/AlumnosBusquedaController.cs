using Gestion.Colegial.Business.Interfaces;
using Gestion.Colegial.Entities;
using Microsoft.AspNetCore.Mvc;
using System.Threading.Tasks;

namespace Gestion.Colegial.Api.Controllers
{
    [ApiController]
    [Route("api/v1/[controller]")]
    public class AlumnosBusquedaController : ControllerBase
    {
        private readonly IAlumnosBusquedaService _service;
        public AlumnosBusquedaController(IAlumnosBusquedaService service) { _service = service; }

        [HttpGet("SearchAsync")]
        public async Task<IActionResult> Search(string Termino)
        {
            Answer answer = await _service.Search(Termino);
            return Ok(answer.Data);
        }
    }
}
