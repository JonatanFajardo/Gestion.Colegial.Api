using Gestion.Colegial.Business.Interfaces;
using Gestion.Colegial.Entities;
using Microsoft.AspNetCore.Mvc;
using System.Threading.Tasks;

namespace Gestion.Colegial.Api.Controllers
{
    [ApiController]
    [Route("api/v1/[controller]")]
    public class DashboardCajeroController : ControllerBase
    {
        private readonly IDashboardCajeroService _service;
        public DashboardCajeroController(IDashboardCajeroService service) { _service = service; }

        [HttpGet("ResumenAsync")]
        public async Task<IActionResult> Resumen(int Usu_Id, DateTime? Fecha)
        {
            Answer answer = await _service.Resumen(Usu_Id, Fecha);
            return Ok(answer.Data);
        }
    }
}
