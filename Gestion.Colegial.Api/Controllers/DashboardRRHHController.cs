using Gestion.Colegial.Business.Interfaces;
using Gestion.Colegial.Entities;
using Microsoft.AspNetCore.Mvc;
using System.Threading.Tasks;

namespace Gestion.Colegial.Api.Controllers
{
    [ApiController]
    [Route("api/v1/[controller]")]
    public class DashboardRRHHController : ControllerBase
    {
        private readonly IDashboardRRHHService _service;
        public DashboardRRHHController(IDashboardRRHHService service) { _service = service; }

        [HttpGet("ResumenAsync")]
        public async Task<IActionResult> Resumen(int Anio, int Mes)
        {
            Answer answer = await _service.Resumen(Anio, Mes);
            return Ok(answer.Data);
        }
    }
}
