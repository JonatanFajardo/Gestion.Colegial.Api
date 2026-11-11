using Gestion.Colegial.Business.Interfaces;
using Gestion.Colegial.Entities;
using Gestion.Colegial.Entities.Entities;
using Microsoft.AspNetCore.Mvc;

namespace Gestion.Colegial.Api.Controllers
{
    /// <summary>
    /// Ofertas de asignatura por año (Fase 5, capa multi-año). Convención de catálogo
    /// del ADM: ListAsync / FindAsync / DetailAsync / CreateAsync / EditAsync / RemoveAsync.
    /// El listado se filtra por año vía ?value={Ani_Id}.
    /// </summary>
    [ApiController]
    [Route("api/v1/[controller]")]
    public class OfertasAnioController : ControllerBase
    {
        private readonly IOfertaAnioService _ofertaAnioService;

        public OfertasAnioController(IOfertaAnioService ofertaAnioService)
        {
            _ofertaAnioService = ofertaAnioService;
        }

        [HttpGet]
        [Route("ListAsync")]
        public async Task<IActionResult> List(int value)
        {
            Answer answer = await _ofertaAnioService.List(value);
            return Ok(answer.Data);
        }

        [HttpGet]
        [Route("FindAsync")]
        public async Task<IActionResult> Find(int value)
        {
            Answer answer = await _ofertaAnioService.Find(value);
            return Ok(answer.Data);
        }

        [HttpGet]
        [Route("DetailAsync")]
        public async Task<IActionResult> Detail(int value)
        {
            Answer answer = await _ofertaAnioService.Find(value);
            return Ok(answer.Data);
        }

        [HttpPost]
        [Route("CreateAsync")]
        public async Task<IActionResult> Create(tbOfertasAnio entity)
        {
            Answer answer = await _ofertaAnioService.Create(entity);
            return Ok(answer.Data);
        }

        [HttpPut]
        [Route("EditAsync")]
        public async Task<IActionResult> Edit(tbOfertasAnio entity)
        {
            Answer answer = await _ofertaAnioService.Edit(entity);
            return Ok(answer.Data);
        }

        [HttpPut]
        [Route("RemoveAsync")]
        public async Task<IActionResult> Remove(int value)
        {
            Answer answer = await _ofertaAnioService.Delete(value);
            return Ok(answer.Data);
        }
    }
}
