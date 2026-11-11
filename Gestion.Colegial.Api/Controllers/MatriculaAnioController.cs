using Gestion.Colegial.Business.Interfaces;
using Gestion.Colegial.Entities;
using Gestion.Colegial.Entities.Entities;
using Microsoft.AspNetCore.Mvc;

namespace Gestion.Colegial.Api.Controllers
{
    /// <summary>
    /// Matrícula por año + promociones (expediente/transcript, capa multi-año,
    /// espejo de academic_year_student_record + promotions de Skuul).
    /// ListBySeccionAsync (value = Sea_Id), ExpedienteAsync (value = Alu_Id),
    /// EnrollAsync (POST), PromoverAsync (POST con año/sección origen y destino).
    /// </summary>
    [ApiController]
    [Route("api/v1/[controller]")]
    public class MatriculaAnioController : ControllerBase
    {
        private readonly IMatriculaAnioService _matriculaAnioService;

        public MatriculaAnioController(IMatriculaAnioService matriculaAnioService)
        {
            _matriculaAnioService = matriculaAnioService;
        }

        /// <summary>Alumnos matriculados en una sección-año. value = Sea_Id.</summary>
        [HttpGet]
        [Route("ListBySeccionAsync")]
        public async Task<IActionResult> ListBySeccion(int value)
        {
            Answer answer = await _matriculaAnioService.ListBySeccion(value);
            return Ok(answer.Data);
        }

        /// <summary>Historial de matrícula del alumno por año (transcript). value = Alu_Id.</summary>
        [HttpGet]
        [Route("ExpedienteAsync")]
        public async Task<IActionResult> Expediente(int value)
        {
            Answer answer = await _matriculaAnioService.Expediente(value);
            return Ok(answer.Data);
        }

        /// <summary>Matricula (o reactiva) al alumno en un año/sección.</summary>
        [HttpPost]
        [Route("EnrollAsync")]
        public async Task<IActionResult> Enroll(tbMatriculaAnio entity)
        {
            Answer answer = await _matriculaAnioService.Enroll(entity);
            return Ok(answer.Data);
        }

        /// <summary>Promueve a los alumnos activos de una sección-año a la del año destino.</summary>
        [HttpPost]
        [Route("PromoverAsync")]
        public async Task<IActionResult> Promover(int anioOrigen, int seccionOrigen, int anioDestino, int seccionDestino)
        {
            Answer answer = await _matriculaAnioService.Promover(anioOrigen, seccionOrigen, anioDestino, seccionDestino);
            return Ok(answer.Data);
        }
    }
}
