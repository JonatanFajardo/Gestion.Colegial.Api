using Gestion.Colegial.Business.Dtos;
using Gestion.Colegial.Business.Services;
using Gestion.Colegial.Entities;
using Microsoft.AspNetCore.Mvc;

namespace Gestion.Colegial.Api.Controllers
{
    [ApiController]
    [Route("api/[controller]")]
    //[Route("api/Encargados")]
    public class EncargadosController : ControllerBase
    {
        private readonly EncargadoService _encargadoService;

        public EncargadosController(EncargadoService encargadoService)
        {
            _encargadoService = encargadoService;
        }

        /// <summary>
        /// Obtiene un objeto.
        /// </summary>
        /// <returns>Objeto tbEncargados.</returns>
        /// <response code="200">Ok. Devuelve el objeto solicitado.</response>
        /// <response code="404">NotFound. No se ha encontrado el objeto solicitado.</response>
        [HttpGet]
        //[ResponseType(typeof(tbEncargados))]
        [Route("ListAsync")]
        public async Task<IActionResult> List()
        {
            Answer answer = await _encargadoService.List();
            return Ok(answer.Data);
        }

        /// <summary>
        /// Obtiene un objeto por su id.
        /// </summary>
        /// <param name="value">Identificador único del objeto.</param>
        /// <returns>Objeto tbEncargados.</returns>
        /// <response code="200">Ok. Devuelve el objeto solicitado.</response>
        /// <response code="400">BadRequest. Conexión no establecida.</response>
        /// <response code="404">NotFound. No se ha encontrado el objeto solicitado.</response>
        [HttpGet]
        //[ResponseType(typeof(tbEncargados))]
        [Route("FindAsync")]
        public async Task<IActionResult> Find(int value)
        {
            //if (value == 0)
            //{
            //    return NotFound();
            //}
            Answer answer = await _encargadoService.Find(value);
            return Ok(answer.Data);
        }

        /// <summary>
        /// Obtiene un objeto por su id.
        /// </summary>
        /// <param name="value">Identificador único del objeto.</param>
        /// <returns>Objeto tbEncargados.</returns>
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
            Answer answer = await _encargadoService.Detail(value);
            return Ok(answer.Data);
        }

        /// <summary>
        /// Crea un nuevo registro.
        /// </summary>
        /// <param name="entity">Recibe los datos a guardar.</param>
        /// <returns>Estado de la peticion completada.</returns>
        /// <response code="200">Ok. Devuelve el objeto solicitado.</response>
        /// <response code="400">BadRequest. Conexión no establecida.</response>
        /// <response code="404">NotFound. No se ha encontrado el objeto solicitado.</response>
        [HttpPost]
        //[ResponseType(typeof(EncargadosFindDto))]
        [Route("CreateAsync")]
        public async Task<IActionResult> Create(EncargadosFindDto entity)
        {
            //if (entity == null)
            //{
            //    return NotFound();
            //}
            Answer answer = await _encargadoService.Create(entity);
            return Ok(answer.Data);
        }

        /// <summary>
        /// Modifica un nuevo registro.
        /// </summary>
        /// <param name="entity">Recibe los datos a modificar.</param>
        /// <returns>Estado de la peticion completada.</returns>
        /// <response code="200">Ok. Devuelve el objeto solicitado.</response>
        /// <response code="400">BadRequest. Conexión no establecida.</response>
        /// <response code="404">NotFound. No se ha encontrado el objeto solicitado.</response>
        //[ResponseType(typeof(EncargadosFindDto))]
        [HttpPut]
        [Route("EditAsync")]
        public async Task<IActionResult> Edit(EncargadosFindDto entity)
        {
            //if (entity == null)
            //{
            //    return NotFound();
            //}
            Answer answer = await _encargadoService.Edit(entity);
            return Ok(answer.Data);
        }

        /// <summary>
        /// Elimina el registro especificado.
        /// </summary>
        /// <param name="value">Identificador único del objeto.</param>
        /// <returns></returns>
        //[ResponseType(typeof(tbEncargados))]
        [HttpPut]
        [Route("RemoveAsync")]
        public async Task<IActionResult> Remove(int value)
        {
            //if (value == 0)
            //{
            //    return NotFound();
            //}
            Answer answer = await _encargadoService.Delete(value);
            return Ok(answer.Data);
        }
    }
}