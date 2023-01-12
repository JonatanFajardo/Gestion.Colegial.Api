using Gestion.Colegial.Business.Services;
using Gestion.Colegial.Entities;
using Gestion.Colegial.Entities.Entities.app;
using Microsoft.AspNetCore.Mvc;

namespace Gestion.Colegial.Api.Controllers
{
    [ApiController]
    [Route("api/[controller]")]
    //[Route("api/NivelesEducativos")]
    public class NivelesEducativosController : ControllerBase
    {
        private readonly NivelEducativoService _nivelEducativoService;

        public NivelesEducativosController(NivelEducativoService nivelEducativoService)
        {
            _nivelEducativoService = nivelEducativoService;
        }

        [HttpGet]
        //[ResponseType(typeof(tbNivelesEducativos))]
        [Route("ListAsync")]
        public async Task<IActionResult> List()
        {
            Answer answer = await _nivelEducativoService.List();
            return Ok(answer.Data);
        }

        [HttpGet]
        //[ResponseType(typeof(tbNivelesEducativos))]
        [Route("FindAsync")]
        public async Task<IActionResult> Find(int value)
        {
            //if (value == 0)
            //{
            //    return NotFound();
            //}
            Answer answer = await _nivelEducativoService.Find(value);
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
            //if (value == 0)
            //{
            //    return NotFound();
            //}
            Answer answer = await _nivelEducativoService.Detail(value);
            return Ok(answer.Data);
        }

        [HttpPost]
        //[ResponseType(typeof(tbNivelesEducativos))]
        [Route("CreateAsync")]
        public async Task<IActionResult> Create(tbNivelesEducativos entity)
        {
            //if (entity == null)
            //{
            //    return NotFound();
            //}
            Answer answer = await _nivelEducativoService.Create(entity);
            return Ok(answer.Data);
        }

        //[ResponseType(typeof(tbNivelesEducativos))]
        [HttpPut]
        [Route("EditAsync")]
        public async Task<IActionResult> Edit(tbNivelesEducativos entity)
        {
            //if (entity == null)
            //{
            //    return NotFound();
            //}
            Answer answer = await _nivelEducativoService.Edit(entity);
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
        [Route("ExistAsync")]
        public async Task<IActionResult> Exist(string value)
        {
            if (value == null)
            {
                return NotFound();
            }
            Answer answer = await _nivelEducativoService.Exist(value);

            if (answer.Access)
            {
                return BadRequest(answer.Message);
            }
            return Ok(answer.Data);
        }

        [HttpPut]
        //[ResponseType(typeof(tbNivelesEducativos))]
        [Route("RemoveAsync")]
        public async Task<IActionResult> Remove(int value)
        {
            //if (value == 0)
            //{
            //    return NotFound();
            //}
            Answer answer = await _nivelEducativoService.Delete(value);
            return Ok(answer.Data);
        }
    }
}
