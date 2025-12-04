using Gestion.Colegial.Business.Interfaces;
using Gestion.Colegial.Entities;
using Gestion.Colegial.Entities.Entities;
using Microsoft.AspNetCore.Mvc;

namespace Gestion.Colegial.Api.Controllers
{
    [ApiController]
    [Route("api/v1/[controller]")]
    //[Route("api/Secciones")]
    public class SeccionesController : ControllerBase
    {
        private readonly ISeccionService _seccionService;

        public SeccionesController(ISeccionService seccionService)
        {
            _seccionService = seccionService;
        }

        [HttpGet]
        //[ResponseType(typeof(tbSecciones))]
        [Route("ListAsync")]
        public async Task<IActionResult> List()
        {
            Answer answer = await _seccionService.List();
            return Ok(answer.Data);
        }

        [HttpGet]
        //[ResponseType(typeof(tbSecciones))]
        [Route("FindAsync")]
        public async Task<IActionResult> Find(int value)
        {
            //if (value == 0)
            //{
            //    return NotFound();
            //}
            Answer answer = await _seccionService.Find(value);
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
            Answer answer = await _seccionService.Detail(value);
            return Ok(answer.Data);
        }

        [HttpPost]
        //[ResponseType(typeof(tbSecciones))]
        [Route("CreateAsync")]
        public async Task<IActionResult> Create(tbSecciones entity)
        {
            //if (entity == null)
            //{
            //    return NotFound();
            //}
            Answer answer = await _seccionService.Create(entity);
            return Ok(answer.Data);
        }

        //[ResponseType(typeof(tbSecciones))]
        [HttpPut]
        [Route("EditAsync")]
        public async Task<IActionResult> Edit(tbSecciones entity)
        {
            //if (entity == null)
            //{
            //    return NotFound();
            //}
            Answer answer = await _seccionService.Edit(entity);
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
            Answer answer = await _seccionService.Exist(value);

            if (answer.Access)
            {
                return BadRequest(answer.Message);
            }
            return Ok(answer.Data);
        }

        [HttpPut]
        //[ResponseType(typeof(tbSecciones))]
        [Route("RemoveAsync")]
        public async Task<IActionResult> Remove(int value)
        {
            //if (value == 0)
            //{
            //    return NotFound();
            //}
            Answer answer = await _seccionService.Delete(value);
            return Ok(answer.Data);
        }

        #region Dropdown

        /// <summary>
        /// Obtiene un objeto.
        /// </summary>
        /// <returns>Estado de la peticion completada.</returns>
        /// <response code="200">Ok. Devuelve el objeto solicitado.</response>
        /// <response code="400">BadRequest. Conexión no establecida.</response>
        /// <response code="404">NotFound. No se ha encontrado el objeto solicitado.</response>
        [HttpGet("SeccionesDropdown")]
        //[ResponseType(typeof(PR_tbSecciones_DropdownResult))]
        //[Route("SeccionesDropdown")]
        public async Task<IActionResult> SeccionesDropdown(int id)
        {
            Answer answer = await _seccionService.SeccionesDropdown(id);
            return Ok(answer.Data);
        }

        #endregion Dropdown
    }
}
