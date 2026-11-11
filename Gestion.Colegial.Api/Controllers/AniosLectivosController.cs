using Gestion.Colegial.Business.Interfaces;
using Gestion.Colegial.Entities;
using Gestion.Colegial.Entities.Entities;
using Microsoft.AspNetCore.Mvc;

namespace Gestion.Colegial.Api.Controllers
{
    /// <summary>
    /// Años lectivos (capa multi-año, hueco #1). Convención de catálogo del ADM:
    /// ListAsync / FindAsync / DetailAsync / CreateAsync / EditAsync / ExistAsync / RemoveAsync,
    /// más ActivoAsync / SetActivoAsync para el "año de trabajo".
    /// </summary>
    [ApiController]
    [Route("api/v1/[controller]")]
    public class AniosLectivosController : ControllerBase
    {
        private readonly IAnioLectivoService _anioLectivoService;

        public AniosLectivosController(IAnioLectivoService anioLectivoService)
        {
            _anioLectivoService = anioLectivoService;
        }

        [HttpGet]
        [Route("ListAsync")]
        public async Task<IActionResult> List()
        {
            Answer answer = await _anioLectivoService.List();
            return Ok(answer.Data);
        }

        [HttpGet]
        [Route("FindAsync")]
        public async Task<IActionResult> Find(int value)
        {
            Answer answer = await _anioLectivoService.Find(value);
            return Ok(answer.Data);
        }

        [HttpGet]
        [Route("DetailAsync")]
        public async Task<IActionResult> Detail(int value)
        {
            Answer answer = await _anioLectivoService.Find(value);
            return Ok(answer.Data);
        }

        [HttpGet]
        [Route("ActivoAsync")]
        public async Task<IActionResult> Activo()
        {
            Answer answer = await _anioLectivoService.Activo();
            return Ok(answer.Data);
        }

        [HttpPost]
        [Route("CreateAsync")]
        public async Task<IActionResult> Create(tbAnioLectivo entity)
        {
            Answer answer = await _anioLectivoService.Create(entity);
            return Ok(answer.Data);
        }

        [HttpPut]
        [Route("EditAsync")]
        public async Task<IActionResult> Edit(tbAnioLectivo entity)
        {
            Answer answer = await _anioLectivoService.Edit(entity);
            return Ok(answer.Data);
        }

        [HttpGet]
        [Route("ExistAsync")]
        public async Task<IActionResult> Exist(string value)
        {
            if (value == null)
            {
                return NotFound();
            }
            Answer answer = await _anioLectivoService.Exist(value);
            if (answer.Access)
            {
                return BadRequest(answer.Message);
            }
            return Ok(answer.Data);
        }

        [HttpPut]
        [Route("RemoveAsync")]
        public async Task<IActionResult> Remove(int value)
        {
            Answer answer = await _anioLectivoService.Delete(value);
            return Ok(answer.Data);
        }

        [HttpPut]
        [Route("SetActivoAsync")]
        public async Task<IActionResult> SetActivo(int value)
        {
            Answer answer = await _anioLectivoService.SetActivo(value);
            return Ok(answer.Data);
        }
    }
}
