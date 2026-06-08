using Gestion.Colegial.Business.Interfaces;
using Gestion.Colegial.Entities;
using Microsoft.AspNetCore.Mvc;
using System.Threading.Tasks;

namespace Gestion.Colegial.Api.Controllers
{
    [ApiController]
    [Route("api/v1/[controller]")]
    public class AgingCuentasController : ControllerBase
    {
        private readonly IAgingCuentasService _service;
        public AgingCuentasController(IAgingCuentasService service) { _service = service; }

        [HttpGet("ListAsync")]
        public async Task<IActionResult> List(DateTime? FechaCorte)
        {
            Answer answer = await _service.List(FechaCorte);
            return Ok(answer.Data);
        }
    }
}
