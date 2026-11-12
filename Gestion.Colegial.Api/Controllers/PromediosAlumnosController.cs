using Gestion.Colegial.Business.Interfaces;
using Gestion.Colegial.Entities;
using Microsoft.AspNetCore.Mvc;
using System;
using System.Threading.Tasks;

namespace Gestion.Colegial.Api.Controllers
{
    [ApiController]
    [Route("api/v1/[controller]")]
    public class PromediosAlumnosController : ControllerBase
    {
        private readonly IPromediosAlumnosService _service;
        public PromediosAlumnosController(IPromediosAlumnosService service) { _service = service; }

        [HttpGet("ListAsync")]
        public async Task<IActionResult> List(int? Anio, int? UmbralBajo)
        {
            int anio = Anio ?? DateTime.Now.Year;
            int umbral = UmbralBajo ?? 70;
            Answer answer = await _service.List(anio, umbral);
            return Ok(answer.Data);
        }
    }
}
