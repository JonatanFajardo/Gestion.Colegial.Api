using Gestion.Colegial.Business.Interfaces;
using Gestion.Colegial.Entities;
using Gestion.Colegial.Entities.Entities;
using Microsoft.AspNetCore.Mvc;

namespace Gestion.Colegial.Api.Controllers
{
    [ApiController]
    [Route("api/v1/[controller]")]
    public class HorarioAlumnosController : ControllerBase
    {
        private readonly IHorarioAlumnosService _horarioAlumnoService;

        public HorarioAlumnosController(IHorarioAlumnosService horarioAlumnoService)
        {
            _horarioAlumnoService = horarioAlumnoService;
        }

        /// <summary>
        /// Obtiene la lista de todos los horarios de alumnos.
        /// </summary>
        /// <returns>Lista de horarios.</returns>
        /// <response code="200">Ok. Devuelve la lista de horarios.</response>
        [HttpGet]
        [Route("ListAsync")]
        public async Task<IActionResult> List()
        {
            Answer answer = await _horarioAlumnoService.List();
            return Ok(answer.Data);
        }

        /// <summary>
        /// Obtiene un horario por su id.
        /// </summary>
        /// <param name="value">Identificador del horario.</param>
        /// <returns>Objeto horario.</returns>
        /// <response code="200">Ok. Devuelve el horario solicitado.</response>
        [HttpGet]
        [Route("FindAsync")]
        public async Task<IActionResult> Find(int value)
        {
            Answer answer = await _horarioAlumnoService.Find(value);
            return Ok(answer.Data);
        }

        /// <summary>
        /// Obtiene los detalles de un horario por su id.
        /// </summary>
        /// <param name="value">Identificador del horario.</param>
        /// <returns>Detalles del horario.</returns>
        /// <response code="200">Ok. Devuelve los detalles del horario.</response>
        [HttpGet]
        [Route("DetailAsync")]
        public async Task<IActionResult> Detail(int value)
        {
            Answer answer = await _horarioAlumnoService.Detail(value);
            return Ok(answer.Data);
        }

        /// <summary>
        /// Crea un nuevo horario de alumno.
        /// </summary>
        /// <param name="entity">Objeto horario a crear.</param>
        /// <returns>Resultado de la operación.</returns>
        /// <response code="200">Ok. Horario creado exitosamente.</response>
        [HttpPost]
        [Route("CreateAsync")]
        public async Task<IActionResult> Create(tbHorarioAlumnos entity)
        {
            Answer answer = await _horarioAlumnoService.Create(entity);
            return Ok(answer.Data);
        }

        /// <summary>
        /// Actualiza un horario existente.
        /// </summary>
        /// <param name="entity">Objeto horario a actualizar.</param>
        /// <returns>Resultado de la operación.</returns>
        /// <response code="200">Ok. Horario actualizado exitosamente.</response>
        [HttpPut]
        [Route("EditAsync")]
        public async Task<IActionResult> Edit(tbHorarioAlumnos entity)
        {
            Answer answer = await _horarioAlumnoService.Edit(entity);
            return Ok(answer.Data);
        }

        /// <summary>
        /// Elimina un horario por su id.
        /// </summary>
        /// <param name="value">Identificador del horario a eliminar.</param>
        /// <returns>Resultado de la operación.</returns>
        /// <response code="200">Ok. Horario eliminado exitosamente.</response>
        [HttpPut]
        [Route("RemoveAsync")]
        public async Task<IActionResult> Remove(int value)
        {
            Answer answer = await _horarioAlumnoService.Delete(value);
            return Ok(answer.Data);
        }
    }
}