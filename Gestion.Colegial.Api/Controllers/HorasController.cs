using Gestion.Colegial.Business.Services;
using Gestion.Colegial.Entities;
using Gestion.Colegial.Entities.Entities.app;
using Microsoft.AspNetCore.Mvc;

namespace Gestion.Colegial.Api.Controllers
{
    [ApiController]
    [Route("api/v1/[controller]")]
    //[Route("api/Horas")]
    public class HorasController : ControllerBase
    {
        private readonly HoraService _horaService;

        public HorasController(HoraService horaService)
        {
            _horaService = horaService;
        }

        [HttpPost]
        //[ResponseType(typeof(tbHoras))]
        [Route("CreateAsync")]
        public async Task<IActionResult> Create(tbHoras entity)
        {
            //if (entity == null)
            //{
            //    return NotFound();
            //}
            Answer answer = await _horaService.Create(entity);
            return Ok(answer.Data);
        }

        //[ResponseType(typeof(tbHoras))]
        [HttpPut]
        [Route("EditAsync")]
        public async Task<IActionResult> Edit(tbHoras entity)
        {
            //if (entity == null)
            //{
            //    return NotFound();
            //}
            Answer answer = await _horaService.Edit(entity);
            return Ok(answer.Data);
        }

        [HttpGet]
        //[ResponseType(typeof(tbHoras))]
        [Route("ListAsync")]
        public async Task<IActionResult> List()
        {
            Answer answer = await _horaService.List();
            return Ok(answer.Data);
        }

        [HttpGet]
        //[ResponseType(typeof(tbHoras))]
        [Route("FindAsync")]
        public async Task<IActionResult> Find(int value)
        {
            //if (value == 0)
            //{
            //    return NotFound();
            //}
            Answer answer = await _horaService.Find(value);
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
        //[HttpGet]
        //    [Route("DetailAsync")]
        //public async Task<IActionResult> Detail(int value)
        //{
        //    if (value == 0)
        //    {
        //        return NotFound();
        //    }
        //    Answer answer = await horaService.Detail(value);
        //    return Ok(answer.Data);
        //}

        [HttpPut]
        //[ResponseType(typeof(tbHoras))]
        [Route("RemoveAsync")]
        public async Task<IActionResult> Remove(int value)
        {
            //if (value == 0)
            //{
            //    return NotFound();
            //}
            Answer answer = await _horaService.Delete(value);
            return Ok(answer.Data);
        }
    }
}