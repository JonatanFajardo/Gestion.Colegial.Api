using Gestion.Colegial.Business.Interfaces;
using Gestion.Colegial.Entities;
using Microsoft.AspNetCore.Mvc;
using System.Threading.Tasks;

namespace Gestion.Colegial.Api.Controllers
{
    [ApiController]
    [Route("api/v1/[controller]")]
    public class BoletinController : ControllerBase
    {
        private readonly IBoletinService _service;
        public BoletinController(IBoletinService service) { _service = service; }

        [HttpGet("FindAsync")]
        public async Task<IActionResult> Find(int Alu_Id, int Anio)
        {
            Answer answer = await _service.Generate(Alu_Id, Anio);
            return Ok(answer.Data);
        }
    }
}
