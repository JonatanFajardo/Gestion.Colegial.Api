using Gestion.Colegial.Business.Services;
using Gestion.Colegial.Entities;
using Gestion.Colegial.Entities.Entities;
using Microsoft.AspNetCore.Mvc;

namespace Gestion.Colegial.Api.Controllers
{
    [ApiController]
    [Route("api/v1/[controller]")]
    //[Route("api/Estados")]
    public class EstadosController : ControllerBase
    {
        private readonly EstadoService _estadoService;

        public EstadosController(EstadoService estadoService)
        {
            _estadoService = estadoService;
        }

        /// <summary>
        /// Obtiene un objeto.
        /// </summary>
        /// <returns>Objeto tbAlumnos.</returns>
        /// <response code="200">Ok. Devuelve el objeto solicitado.</response>
        /// <response code="404">NotFound. No se ha encontrado el objeto solicitado.</response>
        [HttpGet]
        //[ResponseType(typeof(tbEstados))]
        [Route("ListAsync")]
        public async Task<IActionResult> List()
        {
            Answer answer = await _estadoService.List();
            return Ok(answer.Data);
        }

        [HttpGet]
        //[ResponseType(typeof(tbEstados))]
        [Route("FindAsync")]
        public async Task<IActionResult> Find(int value)
        {
            //if (value == 0)
            //{
            //    return NotFound();
            //}
            Answer answer = await _estadoService.Find(value);
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
            Answer answer = await _estadoService.Detail(value);
            return Ok(answer.Data);
        }

        [HttpPost]
        //[ResponseType(typeof(tbEstados))]
        [Route("CreateAsync")]
        public async Task<IActionResult> Create(tbEstados entity)
        {
            //if (entity == null)
            //{
            //    return NotFound();
            //}
            Answer answer = await _estadoService.Create(entity);
            return Ok(answer.Data);
        }

        //[ResponseType(typeof(tbEstados))]
        [HttpPut]
        [Route("EditAsync")]
        public async Task<IActionResult> Edit(tbEstados entity)
        {
            //if (entity == null)
            //{
            //    return NotFound();
            //}
            Answer answer = await _estadoService.Edit(entity);
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
            Answer answer = await _estadoService.Exist(value);

            if (answer.Access)
            {
                return BadRequest(answer.Message);
            }
            return Ok(answer.Data);
        }

        [HttpPut]
        //[ResponseType(typeof(tbEstados))]
        [Route("RemoveAsync")]
        public async Task<IActionResult> Remove(int value)
        {
            //if (value == 0)
            //{
            //    return NotFound();
            //}
            Answer answer = await _estadoService.Delete(value);
            return Ok(answer.Data);
        }
    }
}