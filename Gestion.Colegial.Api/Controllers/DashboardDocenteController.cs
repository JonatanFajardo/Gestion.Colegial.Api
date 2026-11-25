using Gestion.Colegial.Business.Interfaces;
using Gestion.Colegial.Entities;
using Gestion.Colegial.Api.Seguridad;
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

        // El empleado sale siempre del usuario firmado, no de lo que mande el navegador.
        [HttpGet("ResumenAsync")]
        [DatoDelServidor(DatoUsuario.Empleado, "Emp_Id")]
        public async Task<IActionResult> Resumen(int? Emp_Id, int Dia_Id, int Anio)
        {
            Answer answer = await _service.Resumen(Emp_Id ?? 0, Dia_Id, Anio);
            return Ok(answer.Data);
        }
    }
}
