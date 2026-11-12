using Gestion.Colegial.Business.Interfaces;
using Gestion.Colegial.Entities;
using Microsoft.AspNetCore.Mvc;
using System.Threading.Tasks;

namespace Gestion.Colegial.Api.Controllers
{
    [ApiController]
    [Route("api/v1/[controller]")]
    public class DashboardDocenteController : ControllerBase
    {
        private readonly IDashboardDocenteService _service;
        public DashboardDocenteController(IDashboardDocenteService service) { _service = service; }

        [HttpGet("ResumenAsync")]
        public async Task<IActionResult> Resumen(int Emp_Id, int Dia_Id, int Anio)
        {
            Answer answer = await _service.Resumen(Emp_Id, Dia_Id, Anio);
            return Ok(answer.Data);
        }
    }
}
