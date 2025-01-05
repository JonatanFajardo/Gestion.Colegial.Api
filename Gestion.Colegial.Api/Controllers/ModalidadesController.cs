using Gestion.Colegial.Business.Services;
using Gestion.Colegial.Entities;
using Gestion.Colegial.Entities.Entities;
using Microsoft.AspNetCore.Mvc;

namespace Gestion.Colegial.Api.Controllers
{
    [ApiController]
    [Route("api/v1/[controller]")]
    //[Route("api/Modalidades")]
    public class ModalidadesController : ControllerBase
    {
        private readonly ModalidadService _modalidadService;

        public ModalidadesController(ModalidadService modalidadService)
        {
            _modalidadService = modalidadService;
        }

        /// <summary>
        /// Obtiene un objeto.
        /// </summary>
        /// <returns>Objeto tbModalidades.</returns>
        /// <response code="200">Ok. Devuelve el objeto solicitado.</response>
        /// <response code="404">NotFound. No se ha encontrado el objeto solicitado.</response>
        [HttpGet]
        //[ResponseType(typeof(tbModalidades))]
        [Route("ListAsync")]
        public async Task<IActionResult> List()
        {
            Answer answer = await _modalidadService.List();
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
        //[ResponseType(typeof(tbModalidades))]
        [Route("FindAsync")]
        public async Task<IActionResult> Find(int value)
        {
            //if (value == 0)
            //{
            //    return NotFound();
            //}
            Answer answer = await _modalidadService.Find(value);
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
            Answer answer = await _modalidadService.Detail(value);
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
        //[ResponseType(typeof(tbModalidades))]
        [Route("CreateAsync")]
        public async Task<IActionResult> Create(tbModalidades entity)
        {
            //if (entity == null)
            //{
            //    return NotFound();
            //}
            Answer answer = await _modalidadService.Create(entity);
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
        //[ResponseType(typeof(tbModalidades))]
        [HttpPut]
        [Route("EditAsync")]
        public async Task<IActionResult> Edit(tbModalidades entity)
        {
            //if (entity == null)
            //{
            //    return NotFound();
            //}
            Answer answer = await _modalidadService.Edit(entity);
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
            Answer answer = await _modalidadService.Exist(value);

            if (answer.Access)
            {
                return BadRequest(answer.Message);
            }
            return Ok(answer.Data);
        }

        /// <summary>
        /// Elimina el registro especificado.
        /// </summary>
        /// <param name="value">Identificador único del objeto.</param>
        /// <returns></returns>
        //[ResponseType(typeof(tbModalidades))]
        [HttpPut]
        [Route("RemoveAsync")]
        public async Task<IActionResult> Remove(int value)
        {
            //if (value == 0)
            //{
            //    return NotFound();
            //}
            Answer answer = await _modalidadService.Delete(value);
            return Ok(answer.Data);
        }
    }
}
