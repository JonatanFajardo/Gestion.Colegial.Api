using Gestion.Colegial.Business.Interfaces;
using Gestion.Colegial.Entities;
using Microsoft.AspNetCore.Mvc;
using System;
using System.Threading.Tasks;

namespace Gestion.Colegial.Api.Controllers
{
    [ApiController]
    [Route("api/v1/[controller]")]
    public class PagosDelDiaController : ControllerBase
    {
        private readonly IPagosDelDiaService _service;
        public PagosDelDiaController(IPagosDelDiaService service) { _service = service; }

        [HttpGet("ListAsync")]
        public async Task<IActionResult> List(DateTime Fecha)
        {
            Answer answer = await _service.List(Fecha);
            return Ok(answer.Data);
        }
    }
}
