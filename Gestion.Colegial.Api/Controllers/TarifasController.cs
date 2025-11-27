using Gestion.Colegial.Business.Interfaces;
using Gestion.Colegial.Entities;
using Gestion.Colegial.Entities.DTOs.finansas;
using Microsoft.AspNetCore.Mvc;
using Gestion.Colegial.Business.Interfaces.ModuloFinanzas;

namespace Gestion.Colegial.Api.Controllers
{
    [ApiController]
    [Route("api/v1/[controller]")]
    public class TarifasController : ControllerBase
    {
        private readonly ITarifaService _tarifaService;

        public TarifasController(ITarifaService tarifaService)
        {
            _tarifaService = tarifaService;
        }

        [HttpGet]
        [Route("ListAsync")]
        public async Task<IActionResult> List()
        {
            Answer answer = await _tarifaService.List();
            return Ok(answer.Data);
        }

        [HttpGet]
        [Route("FindAsync")]
        public async Task<IActionResult> Find(int value)
        {
            Answer answer = await _tarifaService.Find(value);
            return Ok(answer.Data);
        }

        [HttpGet]
        [Route("DetailAsync")]
        public async Task<IActionResult> Detail(int value)
        {
            Answer answer = await _tarifaService.Detail(value);
            return Ok(answer.Data);
        }

        [HttpPost]
        [Route("CreateAsync")]
        public async Task<IActionResult> Create([FromBody] TarifaFindDto entity)
        {
            Answer answer = await _tarifaService.Create(entity);
            return Ok(answer.Data);
        }

        [HttpPut]
        [Route("EditAsync")]
        public async Task<IActionResult> Edit([FromBody] TarifaFindDto entity)
        {
            Answer answer = await _tarifaService.Edit(entity);
            return Ok(answer.Data);
        }

        [HttpDelete]
        [Route("DeleteAsync")]
        public async Task<IActionResult> Delete(int value)
        {
            Answer answer = await _tarifaService.Delete(value);
            return Ok(answer.Data);
        }

        [HttpGet]
        [Route("GetByConceptoAndNivelAsync")]
        public async Task<IActionResult> GetByConceptoAndNivel(int conceptoId, int nivelId, int anio)
        {
            Answer answer = await _tarifaService.GetByConceptoAndNivel(conceptoId, nivelId, anio);
            return Ok(answer.Data);
        }
    }
}
