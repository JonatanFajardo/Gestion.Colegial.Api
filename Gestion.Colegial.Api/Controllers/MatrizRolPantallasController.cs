using Gestion.Colegial.Business.Interfaces;
using Gestion.Colegial.Entities;
using Microsoft.AspNetCore.Mvc;
using System.Threading.Tasks;

namespace Gestion.Colegial.Api.Controllers
{
    [ApiController]
    [Route("api/v1/[controller]")]
    public class MatrizRolPantallasController : ControllerBase
    {
        private readonly IMatrizRolPantallasService _service;
        public MatrizRolPantallasController(IMatrizRolPantallasService service) { _service = service; }

        [HttpGet("GetAsync")]
        public async Task<IActionResult> Get()
        {
            Answer answer = await _service.Get();
            return Ok(answer.Data);
        }
    }
}
