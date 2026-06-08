using Gestion.Colegial.Business.Interfaces;
using Gestion.Colegial.Entities;
using Microsoft.AspNetCore.Mvc;
using System.Threading.Tasks;

namespace Gestion.Colegial.Api.Controllers
{
    [ApiController]
    [Route("api/v1/[controller]")]
    public class EstadoCuentaController : ControllerBase
    {
        private readonly IEstadoCuentaService _service;
        public EstadoCuentaController(IEstadoCuentaService service) { _service = service; }

        [HttpGet("FindAsync")]
        public async Task<IActionResult> Find(int Alu_Id, int? Anio)
        {
            Answer answer = await _service.Find(Alu_Id, Anio);
            return Ok(answer.Data);
        }
    }
}
