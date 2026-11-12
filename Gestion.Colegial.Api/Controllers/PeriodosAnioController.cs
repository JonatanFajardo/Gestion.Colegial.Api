using Gestion.Colegial.Business.Interfaces;
using Gestion.Colegial.Entities;
using Gestion.Colegial.Entities.Entities;
using Microsoft.AspNetCore.Mvc;

namespace Gestion.Colegial.Api.Controllers
{
    /// <summary>
    /// Períodos de reporte del año lectivo (Fase 2, espejo de Skuul). Convención
    /// de catálogo del ADM: ListAsync (por año → ?value=Ani_Id) / FindAsync /
    /// DetailAsync / CreateAsync / EditAsync / RemoveAsync.
    /// </summary>
    [ApiController]
    [Route("api/v1/[controller]")]
    public class PeriodosAnioController : ControllerBase
    {
        private readonly IPeriodoAnioService _periodoAnioService;

        public PeriodosAnioController(IPeriodoAnioService periodoAnioService)
        {
            _periodoAnioService = periodoAnioService;
        }

        /// <summary>Lista los períodos de un año lectivo. value = Ani_Id.</summary>
        [HttpGet]
        [Route("ListAsync")]
        public async Task<IActionResult> List(int value)
        {
            Answer answer = await _periodoAnioService.List(value);
            return Ok(answer.Data);
        }

        /// <summary>Un período por su Id. value = Pan_Id.</summary>
        [HttpGet]
        [Route("FindAsync")]
        public async Task<IActionResult> Find(int value)
        {
            Answer answer = await _periodoAnioService.Find(value);
            return Ok(answer.Data);
        }

        /// <summary>Detalle de un período. value = Pan_Id.</summary>
        [HttpGet]
        [Route("DetailAsync")]
        public async Task<IActionResult> Detail(int value)
        {
            Answer answer = await _periodoAnioService.Find(value);
            return Ok(answer.Data);
        }

        [HttpPost]
        [Route("CreateAsync")]
        public async Task<IActionResult> Create(tbPeriodosAnio entity)
        {
            Answer answer = await _periodoAnioService.Create(entity);
            return Ok(answer.Data);
        }

        [HttpPut]
        [Route("EditAsync")]
        public async Task<IActionResult> Edit(tbPeriodosAnio entity)
        {
            Answer answer = await _periodoAnioService.Edit(entity);
            return Ok(answer.Data);
        }

        /// <summary>Baja lógica de un período. value = Pan_Id.</summary>
        [HttpPut]
        [Route("RemoveAsync")]
        public async Task<IActionResult> Remove(int value)
        {
            Answer answer = await _periodoAnioService.Delete(value);
            return Ok(answer.Data);
        }
    }
}
