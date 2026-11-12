using Gestion.Colegial.Business.Interfaces;
using Gestion.Colegial.Entities;
using Microsoft.AspNetCore.Mvc;
using System.Threading.Tasks;

namespace Gestion.Colegial.Api.Controllers
{
    [ApiController]
    [Route("api/v1/[controller]")]
    public class KPIsAcademicosController : ControllerBase
    {
        private readonly IKPIsAcademicosService _service;
        public KPIsAcademicosController(IKPIsAcademicosService service) { _service = service; }

        [HttpGet("FindAsync")]
        public async Task<IActionResult> Find(int Anio)
        {
            Answer answer = await _service.Find(Anio);
            return Ok(answer.Data);
        }
    }
}
