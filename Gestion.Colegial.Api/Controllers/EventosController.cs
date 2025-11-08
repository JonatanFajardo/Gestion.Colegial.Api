using Gestion.Colegial.Business.Interfaces;
using Gestion.Colegial.Entities;
using Gestion.Colegial.Entities.Entities;

using Gestion.Colegial.Entities.Entities.app;
using Microsoft.AspNetCore.Mvc;

namespace Gestion.Colegial.Api.Controllers
{
    [ApiController]
    [Route("api/v1/[controller]")]
        public class EventosController : ControllerBase
    {
        private readonly IEventoService _eventoService;

        [HttpGet]
                [Route("ListAsync")]
        public async Task<IActionResult> List()
        {
            Answer answer = await _eventoService.List();
            return Ok(answer.Data);
        }

        [HttpGet]
                [Route("FindAsync")]
        public async Task<IActionResult> Find(int value)
        {
                                                            Answer answer = await _eventoService.Find(value);
            return Ok(answer.Data);
        }

        /// <summary>
        /// Obtiene un objeto por su id.
        /// </summary>
        /// <param name="value">Identificador único del objeto.</param>
        /// <returns>Objeto tbModalidades.</returns>
        /// <response code="200">Ok. Devuelve el objeto solicitado.</response>
        /// <response code="400">BadRequest. Conexión no establecida.</response>
        /// <response code="404">NotFound. No se ha encontrado el objeto solicitado.</response>
        [HttpGet]
        [Route("DetailAsync")]
        public async Task<IActionResult> Detail(int value)
        {
                                                            Answer answer = await _eventoService.Detail(value);
            return Ok(answer.Data);
        }

        [HttpPost]
                [Route("CreateAsync")]
        public async Task<IActionResult> Create(tbEventos entity)
        {
                                                            Answer answer = await _eventoService.Create(entity);
            return Ok(answer.Data);
        }

                [HttpPut]
        [Route("EditAsync")]
        public async Task<IActionResult> Edit(tbEventos entity)
        {
                                                            Answer answer = await _eventoService.Edit(entity);
            return Ok(answer.Data);
        }

        [HttpPut]
                [Route("RemoveAsync")]
        public async Task<IActionResult> Remove(int value)
        {
                                                            Answer answer = await _eventoService.Delete(value);
            return Ok(answer.Data);
        }
    }
}