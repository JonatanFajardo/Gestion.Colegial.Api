using Gestion.Colegial.Business.Interfaces;
using Gestion.Colegial.Entities;
using Microsoft.AspNetCore.Mvc;

namespace Gestion.Colegial.Api.Controllers
{
    [ApiController]
    [Route("api/v1/[controller]")]
    public class EstadosPagoController : ControllerBase
    {
        private readonly IEstadoPagoService _estadoPagoService;

        public EstadosPagoController(IEstadoPagoService estadoPagoService)
        {
            _estadoPagoService = estadoPagoService;
        }

        [HttpGet]
        [Route("ListAsync")]
        public async Task<IActionResult> List()
        {
            Answer answer = await _estadoPagoService.List();
            return Ok(answer.Data);
        }

        [HttpGet]
        [Route("FindAsync")]
        public async Task<IActionResult> Find(int value)
        {
            Answer answer = await _estadoPagoService.Find(value);
            return Ok(answer.Data);
        }

        [HttpGet]
        [Route("DropdownAsync")]
        public async Task<IActionResult> Dropdown()
        {
            Answer answer = await _estadoPagoService.Dropdown();
            return Ok(answer.Data);
        }
    }
}
