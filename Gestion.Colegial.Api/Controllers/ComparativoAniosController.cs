using Gestion.Colegial.Business.Interfaces;
using Gestion.Colegial.Entities;
using Microsoft.AspNetCore.Mvc;
using System.Threading.Tasks;

namespace Gestion.Colegial.Api.Controllers
{
    [ApiController]
    [Route("api/v1/[controller]")]
    public class ComparativoAniosController : ControllerBase
    {
        private readonly IComparativoAniosService _service;
        public ComparativoAniosController(IComparativoAniosService service) { _service = service; }

        [HttpGet("ListAsync")]
        public async Task<IActionResult> List(int AnioBase, int AnioComparacion)
        {
            Answer answer = await _service.List(AnioBase, AnioComparacion);
            return Ok(answer.Data);
        }
    }
}
