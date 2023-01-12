using Gestion.Colegial.Business.Dtos;
using Gestion.Colegial.Business.Services;
using Gestion.Colegial.Entities;
using Microsoft.AspNetCore.Mvc;

namespace Gestion.Colegial.Api.Controllers
{
    [ApiController]
    [Route("api/[controller]")]
    //[Route("api/Empleados")]
    public class EmpleadosController : ControllerBase
    {
        private readonly EmpleadoService _empleadoService;

        public EmpleadosController(EmpleadoService empleadoService)
        {
            _empleadoService = empleadoService;
        }

        /// <summary>
        /// Obtiene un objeto.
        /// </summary>
        /// <returns>Objeto tbEmpleados.</returns>
        /// <response code="200">Ok. Devuelve el objeto solicitado.</response>
        /// <response code="404">NotFound. No se ha encontrado el objeto solicitado.</response>
        [HttpGet]
        //[ResponseType(typeof(tbEmpleados))]
        [Route("ListAsync")]
        public async Task<IActionResult> List()
        {
            Answer answer = await _empleadoService.List();
            return Ok(answer.Data);
        }

        /// <summary>
        /// Obtiene un objeto por su id.
        /// </summary>
        /// <param name="value">Identificador único del objeto.</param>
        /// <returns>Objeto tbEmpleados.</returns>
        /// <response code="200">Ok. Devuelve el objeto solicitado.</response>
        /// <response code="400">BadRequest. Conexión no establecida.</response>
        /// <response code="404">NotFound. No se ha encontrado el objeto solicitado.</response>
        [HttpGet]
        //[ResponseType(typeof(tbEmpleados))]
        [Route("FindAsync")]
        public async Task<IActionResult> Find(int value)
        {
            //if (value == 0)
            //{
            //    return NotFound();
            //}
            Answer answer = await _empleadoService.Find(value);
            return Ok(answer.Data);
        }

        /// <summary>
        /// Obtiene un objeto por su id.
        /// </summary>
        /// <param name="value">Identificador único del objeto.</param>
        /// <returns>Objeto tbEmpleados.</returns>
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
            Answer answer = await _empleadoService.Detail(value);
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
        //[ResponseType(typeof(EmpleadosFindDto))]
        [Route("CreateAsync")]
        public async Task<IActionResult> Create(EmpleadosFindDto entity)
        {
            //if (entity == null)
            //{
            //    return NotFound();
            //}
            Answer answer = await _empleadoService.Create(entity);
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
        //[ResponseType(typeof(EmpleadosFindDto))]
        [HttpPut]
        [Route("EditAsync")]
        public async Task<IActionResult> Edit(EmpleadosFindDto entity)
        {
            //if (entity == null)
            //{
            //    return NotFound();
            //}
            Answer answer = await _empleadoService.Edit(entity);
            return Ok(answer.Data);
        }

        /// <summary>
        /// Obtiene un objeto.
        /// </summary>
        /// <returns>Estado de la peticion completada.</returns>
        /// <response code="200">Ok. Devuelve el objeto solicitado.</response>
        /// <response code="400">BadRequest. Conexión no establecida.</response>
        /// <response code="404">NotFound. No se ha encontrado el objeto solicitado.</response>
        [HttpGet]
        //[ResponseType(typeof(PR_tbTitulos_DropdownResult))]
        [Route("TitulosDropdown")]
        public async Task<IActionResult> TitulosDropdown()
        {
            Answer answer = await _empleadoService.TitulosDropdown();
            return Ok(answer.Data);
        }

        /// <summary>
        /// Obtiene un objeto.
        /// </summary>
        /// <returns>Estado de la peticion completada.</returns>
        /// <response code="200">Ok. Devuelve el objeto solicitado.</response>
        /// <response code="400">BadRequest. Conexión no establecida.</response>
        /// <response code="404">NotFound. No se ha encontrado el objeto solicitado.</response>
        [HttpGet]
        //[ResponseType(typeof(PR_tbCargos_DropdownResult))]
        [Route("CargosDropdown")]
        public async Task<IActionResult> CargosDropdown()
        {
            Answer answer = await _empleadoService.CargosDropdown();
            return Ok(answer.Data);
        }

        /// <summary>
        /// Obtiene un objeto por su id.
        /// </summary>
        /// <param name="value">Identificador único del objeto.</param>
        /// <returns>Objeto tbEmpleados.</returns>
        /// <response code="200">Ok. Devuelve el objeto solicitado.</response>
        /// <response code="400">BadRequest. Conexión no establecida.</response>
        /// <response code="404">NotFound. No se ha encontrado el objeto solicitado.</response>
        //[HttpGet]
        //    [Route("ExistAsync")]
        //public async Task<IActionResult> Exist(string value)
        //{
        //    if (value == null)
        //    {
        //        return NotFound();
        //    }
        //    Answer answer = await _empleadoService.Exist(value);

        //    if (answer.Access)
        //    {
        //        return BadRequest(answer.Message);
        //    }
        //    return Ok(answer.Data);
        //}

        /// <summary>
        /// Elimina el registro especificado.
        /// </summary>
        /// <param name="value">Identificador único del objeto.</param>
        /// <returns></returns>
        //[ResponseType(typeof(tbEmpleados))]
        [HttpPut]
        [Route("RemoveAsync")]
        public async Task<IActionResult> Remove(int value)
        {
            //if (value == 0)
            //{
            //    return NotFound();
            //}
            Answer answer = await _empleadoService.Delete(value);
            return Ok(answer.Data);
        }
    }
}