using Gestion.Colegial.Business.Interfaces;
using Gestion.Colegial.Entities;
using Gestion.Colegial.Entities.Entities;
using Microsoft.AspNetCore.Mvc;

namespace Gestion.Colegial.Api.Controllers
{
    /// <summary>
    /// Escala de notas: traduce el promedio numérico a un concepto para el boletín, más los
    /// umbrales del cuadro de honor. CRUD de las filas de la escala + leer/guardar la config.
    /// </summary>
    [ApiController]
    [Route("api/v1/[controller]")]
    public class EscalaNotasController : ControllerBase
    {
        private readonly IEscalaNotaService _service;

        public EscalaNotasController(IEscalaNotaService service)
        {
            _service = service;
        }

        [HttpGet]
        [Route("ListAsync")]
        public async Task<IActionResult> List()
        {
            Answer answer = await _service.List();
            return Ok(answer.Data);
        }

        [HttpGet]
        [Route("FindAsync")]
        public async Task<IActionResult> Find(int value)
        {
            Answer answer = await _service.Find(value);
            return Ok(answer.Data);
        }

        [HttpGet]
        [Route("DetailAsync")]
        public async Task<IActionResult> Detail(int value)
        {
            Answer answer = await _service.Detail(value);
            return Ok(answer.Data);
        }

        [HttpPost]
        [Route("CreateAsync")]
        public async Task<IActionResult> Create(tbEscalaNotas entity)
        {
            Answer answer = await _service.Create(entity);
            return Ok(answer.Data);
        }

        [HttpPut]
        [Route("EditAsync")]
        public async Task<IActionResult> Edit(tbEscalaNotas entity)
        {
            Answer answer = await _service.Edit(entity);
            return Ok(answer.Data);
        }

        /// <summary>Data = la fila que choca de rango (null si el rango está libre).</summary>
        [HttpGet]
        [Route("SolapaAsync")]
        public async Task<IActionResult> Solapa(decimal desde, decimal hasta, int? id = null)
        {
            Answer answer = await _service.Solapa(desde, hasta, id);
            return Ok(answer.Data);
        }

        [HttpPut]
        [Route("RemoveAsync")]
        public async Task<IActionResult> Remove(int value)
        {
            Answer answer = await _service.Delete(value);
            return Ok(answer.Data);
        }

        /// <summary>Ranking de alumnos de un año que llegan al umbral de honor (filtros opcionales por nivel/sección).</summary>
        [HttpGet]
        [Route("CuadroHonorAsync")]
        public async Task<IActionResult> CuadroHonor(int anio, int? nivId = null, int? secId = null)
        {
            Answer answer = await _service.CuadroHonor(anio, nivId, secId);
            return Ok(answer.Data);
        }

        /// <summary>Umbrales del cuadro de honor (una sola fila).</summary>
        [HttpGet]
        [Route("ConfigAsync")]
        public async Task<IActionResult> Config()
        {
            Answer answer = await _service.ConfigGet();
            return Ok(answer.Data);
        }

        [HttpPut]
        [Route("GuardarConfigAsync")]
        public async Task<IActionResult> GuardarConfig(tbCuadroHonorConfig entity)
        {
            Answer answer = await _service.ConfigSet(entity);
            return Ok(answer.Data);
        }
    }
}
