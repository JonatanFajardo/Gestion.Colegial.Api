using Gestion.Colegial.Business.Interfaces;
using Gestion.Colegial.Entities;
using Microsoft.AspNetCore.Mvc;
using System.Threading.Tasks;

namespace Gestion.Colegial.Api.Controllers
{
    [ApiController]
    [Route("api/v1/[controller]")]
    public class BuscadorController : ControllerBase
    {
        private readonly IBuscadorService _service;

        public BuscadorController(IBuscadorService service)
        {
            _service = service;
        }

        [HttpGet("SearchAsync")]
        public async Task<IActionResult> Search(string q)
        {
            if (string.IsNullOrWhiteSpace(q) || q.Length < 2)
                return Ok(new object[] { });

            Answer answer = await _service.Buscar(q);
            return Ok(answer.Data);
        }
    }
}
