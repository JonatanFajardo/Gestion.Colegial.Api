using Gestion.Colegial.Business.Interfaces;
using Gestion.Colegial.Entities;
using Microsoft.AspNetCore.Mvc;
using System.Threading.Tasks;

namespace Gestion.Colegial.Api.Controllers
{
    [ApiController]
    [Route("api/v1/[controller]")]
    public class DashboardConsultaController : ControllerBase
    {
        private readonly IDashboardConsultaService _service;
        public DashboardConsultaController(IDashboardConsultaService service) { _service = service; }

        [HttpGet("ResumenAsync")]
        public async Task<IActionResult> Resumen(int Anio)
        {
            Answer answer = await _service.Resumen(Anio);
            return Ok(answer.Data);
        }
    }
}
