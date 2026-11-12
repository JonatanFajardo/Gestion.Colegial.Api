using Gestion.Colegial.Business.Interfaces;
using Gestion.Colegial.Entities;
using Microsoft.AspNetCore.Mvc;
using System;
using System.Threading.Tasks;

namespace Gestion.Colegial.Api.Controllers
{
    [ApiController]
    [Route("api/v1/[controller]")]
    public class HistorialTransaccionesController : ControllerBase
    {
        private readonly IHistorialTransaccionesService _service;
        public HistorialTransaccionesController(IHistorialTransaccionesService service) { _service = service; }

        [HttpGet("ListAsync")]
        public async Task<IActionResult> List(int? Alu_Id, DateTime? FechaDesde, DateTime? FechaHasta)
        {
            Answer answer = await _service.List(Alu_Id, FechaDesde, FechaHasta);
            return Ok(answer.Data);
        }
    }
}
