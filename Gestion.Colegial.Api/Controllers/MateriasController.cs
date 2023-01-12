using Gestion.Colegial.Business.Services;
using Gestion.Colegial.Entities;
using Gestion.Colegial.Entities.Entities.app;
using Microsoft.AspNetCore.Mvc;

namespace Gestion.Colegial.Api.Controllers
{
    [ApiController]
    [Route("api/[controller]")]
    //[Route("api/Materias")]
    public class MateriasController : ControllerBase
    {
        private readonly MateriaService _materiaService;

        public MateriasController(MateriaService materiaService)
        {
            _materiaService = materiaService;
        }

        [HttpGet]
        //[ResponseType(typeof(tbMaterias))]
        [Route("ListAsync")]
        public async Task<IActionResult> List()
        {
            Answer answer = await _materiaService.List();
            return Ok(answer.Data);
        }

        [HttpGet]
        //[ResponseType(typeof(tbMaterias))]
        [Route("FindAsync")]
        public async Task<IActionResult> Find(int value)
        {
            //if (value == 0)
            //{
            //    return NotFound();
            //}
            Answer answer = await _materiaService.Find(value);
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
            Answer answer = await _materiaService.Detail(value);
            return Ok(answer.Data);
        }

        [HttpPost]
        //[ResponseType(typeof(tbMaterias))]
        [Route("CreateAsync")]
        public async Task<IActionResult> Create(tbMaterias entity)
        {
            //if (entity == null)
            //{
            //    return NotFound();
            //}
            Answer answer = await _materiaService.Create(entity);
            return Ok(answer.Data);
        }

        //[ResponseType(typeof(tbMaterias))]
        [HttpPut]
        [Route("EditAsync")]
        public async Task<IActionResult> Edit(tbMaterias entity)
        {
            //if (entity == null)
            //{
            //    return NotFound();
            //}
            Answer answer = await _materiaService.Edit(entity);
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
            Answer answer = await _materiaService.Exist(value);

            if (answer.Access)
            {
                return BadRequest(answer.Message);
            }
            return Ok(answer.Data);
        }

        [HttpPut]
        //[ResponseType(typeof(tbMaterias))]
        [Route("RemoveAsync")]
        public async Task<IActionResult> Remove(int value)
        {
            //if (value == 0)
            //{
            //    return NotFound();
            //}
            Answer answer = await _materiaService.Delete(value);
            return Ok(answer.Data);
        }
    }
}
