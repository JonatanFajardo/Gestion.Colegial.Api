using Gestion.Colegial.Business.Interfaces;
using Gestion.Colegial.Entities;
using Microsoft.AspNetCore.Mvc;
using System.Threading.Tasks;

namespace Gestion.Colegial.Api.Controllers
{
    [ApiController]
    [Route("api/v1/[controller]")]
    public class DashboardAdminController : ControllerBase
    {
        private readonly IDashboardAdminService _service;
        public DashboardAdminController(IDashboardAdminService service) { _service = service; }

        [HttpGet("ResumenAsync")]
        public async Task<IActionResult> Resumen()
        {
            Answer answer = await _service.Resumen();
            return Ok(answer.Data);
        }
    }
}
