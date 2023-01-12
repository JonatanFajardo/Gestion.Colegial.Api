using Gestion.Colegial.Business.Dtos;
using Gestion.Colegial.Business.Services;
using Gestion.Colegial.Entities;
using Microsoft.AspNetCore.Mvc;

namespace Gestion.Colegial.Api.Controllers
{
    [ApiController]
    [Route("api/v1/[controller]")]
    //[Route("api/-Alumnos")]
    public class AlumnosController : ControllerBase
    {
        private readonly AlumnoService _alumnoService;

        public AlumnosController(AlumnoService alumnoService)
        {
            _alumnoService = alumnoService;
        }

        /// <summary>
        /// Obtiene un objeto.
        /// </summary>
        /// <returns>Objeto tbAlumnos.</returns>
        /// <response code="200">Ok. Devuelve el objeto solicitado.</response>
        /// <response code="404">NotFound. No se ha encontrado el objeto solicitado.</response>
        [HttpGet("ListAsync")]
        //[ResponseType(typeof(tbAlumnos))]
        //[Route("ListAsync")]
        public async Task<IActionResult> List()
        {
            Answer answer = await _alumnoService.List();
            return Ok(answer.Data);
        }

        /// <summary>
        /// Obtiene un objeto por su id.
        /// </summary>
        /// <param name="value">Identificador único del objeto.</param>
        /// <returns>Objeto tbAlumnos.</returns>
        /// <response code="200">Ok. Devuelve el objeto solicitado.</response>
        /// <response code="400">BadRequest. Conexión no establecida.</response>
        /// <response code="404">NotFound. No se ha encontrado el objeto solicitado.</response>
        [HttpGet("FindAsync")]
        //[ResponseType(typeof(tbAlumnos))]
        //[Route("FindAsync")]
        public async Task<IActionResult> Find(int value)
        {
            //if (value == 0)
            //{
            //    return NotFound();
            //}
            Answer answer = await _alumnoService.Find(value);
            return Ok(answer.Data);
        }

        /// <summary>
        /// Obtiene un objeto por su id.
        /// </summary>
        /// <param name="value">Identificador único del objeto.</param>
        /// <returns>Objeto tbAlumnos.</returns>
        /// <response code="200">Ok. Devuelve el objeto solicitado.</response>
        /// <response code="400">BadRequest. Conexión no establecida.</response>
        /// <response code="404">NotFound. No se ha encontrado el objeto solicitado.</response("DetailAsync")>
        [HttpGet("DetailAsync")]
        //[Route("DetailAsync")]
        public async Task<IActionResult> Detail(int value)
        {
            //if (value == 0)
            //{
            //    return NotFound();
            //}
            Answer answer = await _alumnoService.Detail(value);
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
        [HttpPost("CreateAsync")]
        //[ResponseType(typeof(AlumnosFindDto))]
        //[Route("CreateAsync")]
        public async Task<IActionResult> Create(AlumnosFindDto entity)
        {
            //if (entity == null)
            //{
            //    return NotFound();
            //}
            Answer answer = await _alumnoService.Create(entity);
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
        //[ResponseType(typeof(tbAlumnos))("EditAsync")]
        [HttpPut("EditAsync")]
        //[Route("EditAsync")]
        public async Task<IActionResult> Edit(AlumnosFindDto entity)
        {
            //if (entity == null)
            //{
            //    return NotFound();
            //}
            Answer answer = await _alumnoService.Edit(entity);
            return Ok(answer.Data);
        }

        /// <summary>
        /// Elimina el registro especificado.
        /// </summary>
        /// <param name="value">Identificador único del objeto.</param>
        /// <returns></returns>
        //[ResponseType(typeof(tbAlumnos))("RemoveAsync")]
        [HttpPut("RemoveAsync")]
        //[Route("RemoveAsync")]
        public async Task<IActionResult> Remove(int value)
        {
            //if (value == 0)
            //{
            //    return NotFound();
            //}
            Answer answer = await _alumnoService.Delete(value);
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
        [HttpGet("NivelesEducativosDropdown")]
        //[ResponseType(typeof(PR_tbNivelesEducativos_DropdownResult))]
        //[Route("NivelesEducativosDropdown")]
        public async Task<IActionResult> NivelesEducativosDropdown()
        {
            Answer answer = await _alumnoService.NivelesEducativosDropdown();
            return Ok(answer.Data);
        }

        /// <summary>
        /// Obtiene un objeto.
        /// </summary>
        /// <returns>Estado de la peticion completada.</returns>
        /// <response code="200">Ok. Devuelve el objeto solicitado.</response>
        /// <response code="400">BadRequest. Conexión no establecida.</response>
        /// <response code="404">NotFound. No se ha encontrado el objeto solicitado.</response>
        [HttpGet("CursosNivelesDropdown")]
        //[ResponseType(typeof(PR_tbCursosNiveles_DropdownResult))]
        //[Route("CursosNivelesDropdown")]
        public async Task<IActionResult> CursosNivelesDropdown(int id)
        {
            Answer answer = await _alumnoService.CursosNivelesDropdown(id);
            return Ok(answer.Data);
        }

        /// <summary>
        /// Obtiene un objeto.
        /// </summary>
        /// <returns>Estado de la peticion completada.</returns>
        /// <response code="200">Ok. Devuelve el objeto solicitado.</response>
        /// <response code="400">BadRequest. Conexión no establecida.</response>
        /// <response code="404">NotFound. No se ha encontrado el objeto solicitado.</response>
        [HttpGet("ModalidadesDropdown")]
        //[ResponseType(typeof(PR_tbModalidades_DropdownResult))]
        //[Route("ModalidadesDropdown")]
        public async Task<IActionResult> ModalidadesDropdown(int id)
        {
            Answer answer = await _alumnoService.ModalidadesDropdown(id);
            return Ok(answer.Data);
        }

        /// <summary>
        /// Obtiene un objeto.
        /// </summary>
        /// <returns>Estado de la peticion completada.</returns>
        /// <response code="200">Ok. Devuelve el objeto solicitado.</response>
        /// <response code="400">BadRequest. Conexión no establecida.</response>
        /// <response code="404">NotFound. No se ha encontrado el objeto solicitado.</response>
        [HttpGet("CursosDropdown")]
        //[ResponseType(typeof(PR_tbCursos_DropdownResult))]
        //[Route("CursosDropdown")]
        public async Task<IActionResult> CursosDropdown(int id)
        {
            Answer answer = await _alumnoService.CursosDropdown(id);
            return Ok(answer.Data);
        }

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
            Answer answer = await _alumnoService.SeccionesDropdown(id);
            return Ok(answer.Data);
        }

        /// <summary>
        /// Obtiene un objeto.
        /// </summary>
        /// <returns>Estado de la peticion completada.</returns>
        /// <response code="200">Ok. Devuelve el objeto solicitado.</response>
        /// <response code="400">BadRequest. Conexión no establecida.</response>
        /// <response code="404">NotFound. No se ha encontrado el objeto solicitado.</response>
        [HttpGet("EstadosDropdown")]
        //[ResponseType(typeof(PR_tbEstados_DropdownResult))]
        //[Route("EstadosDropdown")]
        public async Task<IActionResult> EstadosDropdown()
        {
            Answer answer = await _alumnoService.EstadosDropdown();
            return Ok(answer.Data);
        }

        #endregion Dropdown
    }
}