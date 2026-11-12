using Gestion.Colegial.Business.Interfaces;
using Gestion.Colegial.Entities;
using Gestion.Colegial.Entities.Entities;
using Microsoft.AspNetCore.Mvc;

namespace Gestion.Colegial.Api.Controllers
{
    [ApiController]
    [Route("api/v1/[controller]")]
    public class MatriculasController : ControllerBase
    {
        private readonly IMatriculaService _matriculaService;

        public MatriculasController(IMatriculaService matriculaService)
        {
            _matriculaService = matriculaService;
        }

        /// <summary>
        /// Lista las matrículas de un año lectivo, con la descripción del alumno, grado, sección y estado.
        /// </summary>
        /// <param name="anio">Año lectivo a consultar.</param>
        /// <returns>Listado de PR_tbMatriculas_ListResult.</returns>
        [HttpGet]
        [Route("List")]
        public async Task<IActionResult> List(int anio)
        {
            Answer answer = await _matriculaService.List(anio);
            return Ok(answer.Data);
        }

        /// <summary>
        /// Obtiene una matrícula por su identificador único.
        /// </summary>
        /// <param name="id">Identificador único de la matrícula.</param>
        [HttpGet]
        [Route("Find")]
        public async Task<IActionResult> Find(int id)
        {
            Answer answer = await _matriculaService.Find(id);
            return Ok(answer.Data);
        }

        /// <summary>
        /// Registra una nueva matrícula.
        /// </summary>
        /// <param name="entity">Datos de la matrícula a registrar.</param>
        [HttpPost]
        [Route("Insert")]
        public async Task<IActionResult> Insert(tbMatriculas entity)
        {
            Answer answer = await _matriculaService.Create(entity);
            return Ok(answer.Data);
        }

        /// <summary>
        /// Modifica una matrícula existente.
        /// </summary>
        /// <param name="entity">Datos de la matrícula a modificar.</param>
        [HttpPut]
        [Route("Update")]
        public async Task<IActionResult> Update(tbMatriculas entity)
        {
            Answer answer = await _matriculaService.Edit(entity);
            return Ok(answer.Data);
        }

        /// <summary>
        /// Elimina (baja lógica) una matrícula.
        /// </summary>
        /// <param name="id">Identificador único de la matrícula.</param>
        [HttpDelete]
        [Route("Delete")]
        public async Task<IActionResult> Delete(int id)
        {
            Answer answer = await _matriculaService.Delete(id);
            return Ok(answer.Data);
        }
    }
}
