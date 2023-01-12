using Gestion.Colegial.Business.Services;
using Gestion.Colegial.Entities;
using Gestion.Colegial.Entities.Entities.app;
using Microsoft.AspNetCore.Mvc;

namespace Gestion.Colegial.Api.Controllers
{
    [ApiController]
    [Route("api/[controller]")]
    //[Route("api/Cursos")]
    public class CursosController : ControllerBase
    {
        private readonly CursoService _cursoService;

        public CursosController(CursoService cursoService)
        {
            _cursoService = cursoService;
        }

        /// <summary>
        /// Obtiene un objeto.
        /// </summary>
        /// <returns>Objeto tbAlumnos.</returns>
        /// <response code="200">Ok. Devuelve el objeto solicitado.</response>
        /// <response code="404">NotFound. No se ha encontrado el objeto solicitado.</response>
        [HttpGet]
        //[ResponseType(typeof(tbCursos))]
        [Route("ListAsync")]
        public async Task<IActionResult> List()
        {
            Answer answer = await _cursoService.List();
            return Ok(answer.Data);
        }

        [HttpGet]
        //[ResponseType(typeof(tbCursos))]
        [Route("FindAsync")]
        public async Task<IActionResult> Find(int value)
        {
            //if (value == 0)
            //{
            //    return NotFound();
            //}
            Answer answer = await _cursoService.Find(value);
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
            Answer answer = await _cursoService.Detail(value);
            return Ok(answer.Data);
        }

        [HttpPost]
        //[ResponseType(typeof(tbCursos))]
        [Route("CreateAsync")]
        public async Task<IActionResult> Create(tbCursos entity)
        {
            //if (entity == null)
            //{
            //    return NotFound();
            //}
            Answer answer = await _cursoService.Create(entity);
            return Ok(answer.Data);
        }

        //[ResponseType(typeof(tbCursos))]
        [HttpPut]
        [Route("EditAsync")]
        public async Task<IActionResult> Edit(tbCursos entity)
        {
            //if (entity == null)
            //{
            //    return NotFound();
            //}
            Answer answer = await _cursoService.Edit(entity);
            return Ok(answer.Data);
        }

        //[HttpGet]
        //    [Route("ExistAsync")]
        //public async Task<IActionResult> Exist(string value)
        //{
        //    if (value == null)
        //    {
        //        return NotFound();
        //    }
        //    Answer answer = await _cursoService.Exist(value);

        //    if (answer.Access)
        //    {
        //        return BadRequest(answer.Message);
        //    }
        //    return Ok(answer.Data);
        //}

        /// <summary>
        /// Obtiene un objeto por su id.
        /// </summary>
        /// <param name="value">Identificador único del objeto.</param>
        /// <returns>Objeto tbModalidades.</returns>
        /// <response code="200">Ok. Devuelve el objeto solicitado.</response>
        /// <response code="400">BadRequest. Conexión no establecida.</response>
        /// <response code="404">NotFound. No se ha encontrado el objeto solicitado.</response>
        [HttpPut]
        //[ResponseType(typeof(tbCursos))]
        [Route("RemoveAsync")]
        public async Task<IActionResult> Remove(int value)
        {
            //if (value == 0)
            //{
            //    return NotFound();
            //}
            Answer answer = await _cursoService.Delete(value);
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
        [HttpGet]
        //[ResponseType(typeof(PR_tbNivelesEducativos_DropdownResult))]
        [Route("NivelesEducativosDropdown")]
        public async Task<IActionResult> NivelesEducativosDropdown()
        {
            Answer answer = await _cursoService.NivelesEducativosDropdown();
            return Ok(answer.Data);
        }

        #endregion Dropdown

        #region CheckList

        /// <summary>
        /// Obtiene un objeto.
        /// </summary>
        /// <returns>Estado de la peticion completada.</returns>
        /// <response code="200">Ok. Devuelve el objeto solicitado.</response>
        /// <response code="400">BadRequest. Conexión no establecida.</response>
        /// <response code="404">NotFound. No se ha encontrado el objeto solicitado.</response>
        [HttpGet]
        //[ResponseType(typeof(PR_tbModalidades_DropdownResult))]
        [Route("ModalidadesList")]
        public async Task<IActionResult> ModalidadesList()
        {
            Answer answer = await _cursoService.ModalidadesList();
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
        //[ResponseType(typeof(PR_tbCursosNiveles_DropdownResult))]
        [Route("CursosNivelesList")]
        public async Task<IActionResult> CursosNivelesList()
        {
            Answer answer = await _cursoService.CursosNivelesList();
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
        //[ResponseType(typeof(PR_tbMaterias_DropdownResult))]
        [Route("MateriasList")]
        public async Task<IActionResult> MateriasList()
        {
            Answer answer = await _cursoService.MateriasList();
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
        //[ResponseType(typeof(PR_tbSecciones_DropdownResult))]
        [Route("SeccionesList")]
        public async Task<IActionResult> SeccionesList()
        {
            Answer answer = await _cursoService.SeccionesList();
            return Ok(answer.Data);
        }

        #endregion CheckList

        #region CursosModalidades

        [HttpGet]
        //[ResponseType(typeof(tbCursos))]
        [Route("CursosModalidadesFind")]
        public async Task<IActionResult> CursosModalidadesFind(int value)
        {
            //if (value == 0)
            //{
            //    return NotFound();
            //}
            Answer answer = await _cursoService.CursosModalidadesFind(value);
            return Ok(answer.Data);
        }

        [HttpPost]
        //[ResponseType(typeof(tbCursos))]
        [Route("CursosModalidadesCreate")]
        public async Task<IActionResult> CursosModalidadesCreate(tbCursos entity)
        {
            //if (entity == null)
            //{
            //    return NotFound();
            //}
            Answer answer = await _cursoService.CursosModalidadesCreate(entity);
            return Ok(answer.Data);
        }

        //[ResponseType(typeof(tbCursos))]
        [HttpPut]
        [Route("CursosModalidadesEdit")]
        public async Task<IActionResult> CursosModalidadesEdit(tbCursos entity)
        {
            //if (entity == null)
            //{
            //    return NotFound();
            //}
            Answer answer = await _cursoService.CursosModalidadesEdit(entity);
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
        //[HttpPut]
        ////[ResponseType(typeof(tbCursos))]
        //    [Route("CursosModalidadesRemove")]
        //public async Task<IActionResult> CursosModalidadesRemove(int value)
        //{
        //    if (value == 0)
        //    {
        //        return NotFound();
        //    }
        //    Answer answer = await _cursoService.CursosModalidadesDelete(value);
        //    return Ok(answer.Data);
        //}

        #endregion CursosModalidades

        #region CursosMaterias

        [HttpGet]
        //[ResponseType(typeof(tbCursos))]
        [Route("CursosMateriasFind")]
        public async Task<IActionResult> CursosMateriasFind(int value)
        {
            //if (value == 0)
            //{
            //    return NotFound();
            //}
            Answer answer = await _cursoService.CursosMateriasFind(value);
            return Ok(answer.Data);
        }

        [HttpPost]
        //[ResponseType(typeof(tbCursos))]
        [Route("CursosMateriasCreate")]
        public async Task<IActionResult> CursosMateriasCreate(tbCursos entity)
        {
            //if (entity == null)
            //{
            //    return NotFound();
            //}
            Answer answer = await _cursoService.CursosMateriasCreate(entity);
            return Ok(answer.Data);
        }

        //[ResponseType(typeof(tbCursos))]
        [HttpPut]
        [Route("CursosMateriasEdit")]
        public async Task<IActionResult> CursosMateriasEdit(tbCursos entity)
        {
            //if (entity == null)
            //{
            //    return NotFound();
            //}
            Answer answer = await _cursoService.CursosMateriasEdit(entity);
            return Ok(answer.Data);
        }

        /// <summary>
        /// Obtiene un objeto por su id.
        /// </summary>
        /// <param name="value">Identificador único del objeto.</param>
        /// <returns>Objeto tbMaterias.</returns>
        /// <response code="200">Ok. Devuelve el objeto solicitado.</response>
        /// <response code="400">BadRequest. Conexión no establecida.</response>
        /// <response code="404">NotFound. No se ha encontrado el objeto solicitado.</response>
        [HttpPut]
        //[ResponseType(typeof(tbCursos))]
        [Route("CursosMateriasRemove")]
        public async Task<IActionResult> CursosMateriasRemove(int value)
        {
            //if (value == 0)
            //{
            //    return NotFound();
            //}
            Answer answer = await _cursoService.CursosMateriasDelete(value);
            return Ok(answer.Data);
        }

        #endregion CursosMaterias

        #region CursosNiveles

        [HttpGet]
        //[ResponseType(typeof(tbCursos))]
        [Route("CursosNivelesFind")]
        public async Task<IActionResult> CursosNivelesFind(int value)
        {
            //if (value == 0)
            //{
            //    return NotFound();
            //}
            Answer answer = await _cursoService.CursosNivelesFind(value);
            return Ok(answer.Data);
        }

        [HttpPost]
        //[ResponseType(typeof(tbCursos))]
        [Route("CursosNivelesCreate")]
        public async Task<IActionResult> CursosNivelesCreate(tbCursos entity)
        {
            //if (entity == null)
            //{
            //    return NotFound();
            //}
            Answer answer = await _cursoService.CursosNivelesCreate(entity);
            return Ok(answer.Data);
        }

        //[ResponseType(typeof(tbCursos))]
        [HttpPut]
        [Route("CursosNivelesEdit")]
        public async Task<IActionResult> CursosNivelesEdit(tbCursos entity)
        {
            //if (entity == null)
            //{
            //    return NotFound();
            //}
            Answer answer = await _cursoService.CursosNivelesEdit(entity);
            return Ok(answer.Data);
        }

        /// <summary>
        /// Obtiene un objeto por su id.
        /// </summary>
        /// <param name="value">Identificador único del objeto.</param>
        /// <returns>Objeto tbNiveles.</returns>
        /// <response code="200">Ok. Devuelve el objeto solicitado.</response>
        /// <response code="400">BadRequest. Conexión no establecida.</response>
        /// <response code="404">NotFound. No se ha encontrado el objeto solicitado.</response>
        [HttpPut]
        //[ResponseType(typeof(tbCursos))]
        [Route("CursosNivelesRemove")]
        public async Task<IActionResult> CursosNivelesRemove(int value)
        {
            //if (value == 0)
            //{
            //    return NotFound();
            //}
            Answer answer = await _cursoService.CursosNivelesDelete(value);
            return Ok(answer.Data);
        }

        #endregion CursosNiveles

        #region CursosSecciones

        [HttpGet]
        //[ResponseType(typeof(tbCursos))]
        [Route("CursosSeccionesFind")]
        public async Task<IActionResult> CursosSeccionesFind(int value)
        {
            //if (value == 0)
            //{
            //    return NotFound();
            //}
            Answer answer = await _cursoService.CursosSeccionesFind(value);
            return Ok(answer.Data);
        }

        [HttpPost]
        //[ResponseType(typeof(tbCursos))]
        [Route("CursosSeccionesCreate")]
        public async Task<IActionResult> CursosSeccionesCreate(tbCursos entity)
        {
            //if (entity == null)
            //{
            //    return NotFound();
            //}
            Answer answer = await _cursoService.CursosSeccionesCreate(entity);
            return Ok(answer.Data);
        }

        //[ResponseType(typeof(tbCursos))]
        [HttpPut]
        [Route("CursosSeccionesEdit")]
        public async Task<IActionResult> CursosSeccionesEdit(tbCursos entity)
        {
            //if (entity == null)
            //{
            //    return NotFound();
            //}
            Answer answer = await _cursoService.CursosSeccionesEdit(entity);
            return Ok(answer.Data);
        }

        /// <summary>
        /// Obtiene un objeto por su id.
        /// </summary>
        /// <param name="value">Identificador único del objeto.</param>
        /// <returns>Objeto tbSecciones.</returns>
        /// <response code="200">Ok. Devuelve el objeto solicitado.</response>
        /// <response code="400">BadRequest. Conexión no establecida.</response>
        /// <response code="404">NotFound. No se ha encontrado el objeto solicitado.</response>
        [HttpPut]
        //[ResponseType(typeof(tbCursos))]
        [Route("CursosSeccionesRemove")]
        public async Task<IActionResult> CursosSeccionesRemove(int value)
        {
            //if (value == 0)
            //{
            //    return NotFound();
            //}
            Answer answer = await _cursoService.CursosSeccionesDelete(value);
            return Ok(answer.Data);
        }

        #endregion CursosSecciones
    }
}