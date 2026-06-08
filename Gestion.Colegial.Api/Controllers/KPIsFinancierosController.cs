using Gestion.Colegial.Business.Interfaces;
using Gestion.Colegial.Entities;
using Microsoft.AspNetCore.Mvc;
using System.Threading.Tasks;

namespace Gestion.Colegial.Api.Controllers
{
    [ApiController]
    [Route("api/v1/[controller]")]
    public class KPIsFinancierosController : ControllerBase
    {
        private readonly IKPIsFinancierosService _service;
        public KPIsFinancierosController(IKPIsFinancierosService service) { _service = service; }

        [HttpGet("FindAsync")]
        public async Task<IActionResult> Find(int Anio, int? Mes)
        {
            Answer answer = await _service.Find(Anio, Mes);
            return Ok(answer.Data);
        }
    }
}
