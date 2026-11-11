using Gestion.Colegial.Business.Interfaces;
using Gestion.Colegial.Entities;
using Gestion.Colegial.Entities.Entities;
using Microsoft.AspNetCore.Mvc;

namespace Gestion.Colegial.Api.Controllers
{
    /// <summary>
    /// Secciones por año lectivo + profesor guía (Fase 4 — Clases y profesores,
    /// espejo de academic_cycle_sections de Skuul). Convención de catálogo del ADM:
    /// ListAsync (filtra por año = ?value={aniId}), FindAsync / DetailAsync,
    /// CreateAsync (POST), EditAsync (PUT), RemoveAsync (PUT, baja lógica).
    /// </summary>
    [ApiController]
    [Route("api/v1/[controller]")]
    public class SeccionesAnioController : ControllerBase
    {
        private readonly ISeccionAnioService _seccionAnioService;

        public SeccionesAnioController(ISeccionAnioService seccionAnioService)
        {
            _seccionAnioService = seccionAnioService;
        }

        /// <summary>Lista las secciones vivas de un año lectivo. value = Ani_Id.</summary>
        [HttpGet]
        [Route("ListAsync")]
        public async Task<IActionResult> List(int value)
        {
            Answer answer = await _seccionAnioService.List(value);
            return Ok(answer.Data);
        }

        [HttpGet]
        [Route("FindAsync")]
        public async Task<IActionResult> Find(int value)
        {
            Answer answer = await _seccionAnioService.Find(value);
            return Ok(answer.Data);
        }

        [HttpGet]
        [Route("DetailAsync")]
        public async Task<IActionResult> Detail(int value)
        {
            Answer answer = await _seccionAnioService.Find(value);
            return Ok(answer.Data);
        }

        [HttpPost]
        [Route("CreateAsync")]
        public async Task<IActionResult> Create(tbSeccionesAnio entity)
        {
            Answer answer = await _seccionAnioService.Create(entity);
            return Ok(answer.Data);
        }

        [HttpPut]
        [Route("EditAsync")]
        public async Task<IActionResult> Edit(tbSeccionesAnio entity)
        {
            Answer answer = await _seccionAnioService.Edit(entity);
            return Ok(answer.Data);
        }

        [HttpPut]
        [Route("RemoveAsync")]
        public async Task<IActionResult> Remove(int value)
        {
            Answer answer = await _seccionAnioService.Delete(value);
            return Ok(answer.Data);
        }
    }
}
