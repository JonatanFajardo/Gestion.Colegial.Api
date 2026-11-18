using Gestion.Colegial.Business.Interfaces;
using Gestion.Colegial.Entities;
using Gestion.Colegial.Entities.DTOs;
using Gestion.Colegial.Entities.Entities;
using Microsoft.AspNetCore.Mvc;

namespace Gestion.Colegial.Api.Controllers
{
    /// <summary>
    /// Lista de espera de admisión (espejo de Skuul "admission waitlist"): aspirantes que todavía
    /// no son alumnos, su cola por año + grado y el cupo de cada grado.
    /// Las escrituras siempre responden { Ok, Id, Estado, Posicion, PosicionCola, EnCola, Grado, AluId, Aviso, Mensaje }.
    /// </summary>
    [ApiController]
    [Route("api/v1/[controller]")]
    public class AspirantesController : ControllerBase
    {
        private readonly IAspirantesService _service;

        public AspirantesController(IAspirantesService service)
        {
            _service = service;
        }

        private static object Fallo(Answer answer, string general) => new
        {
            Ok = false, Id = 0, Estado = (string?)null, Posicion = 0, PosicionCola = (long?)null, EnCola = 0,
            Grado = (string?)null, AluId = (int?)null, Aviso = (string?)null, Mensaje = answer.Message ?? general
        };

        /// <summary>Años para el selector, con el que se muestra por defecto.</summary>
        [HttpGet]
        [Route("AniosAsync")]
        public async Task<IActionResult> Anios() => Ok((await _service.Anios()).Data);

        /// <summary>Cupo y demanda por grado de un año.</summary>
        [HttpGet]
        [Route("ResumenAsync")]
        public async Task<IActionResult> Resumen(int aniId) => Ok((await _service.Resumen(aniId)).Data);

        /// <summary>Aspirantes de un año en el orden de la cola.</summary>
        [HttpGet]
        [Route("ListAsync")]
        public async Task<IActionResult> List(int aniId) => Ok((await _service.List(aniId)).Data);

        /// <summary>Un aspirante; respuesta vacía si no existe.</summary>
        [HttpGet]
        [Route("FindAsync")]
        public async Task<IActionResult> Find(int value) => Ok((await _service.Find(value)).Data);

        [HttpGet]
        [Route("HistorialAsync")]
        public async Task<IActionResult> Historial(int value) => Ok((await _service.Historial(value)).Data);

        /// <summary>Cursos (carrera / plan) que se imparten en un grado.</summary>
        [HttpGet]
        [Route("CursosAsync")]
        public async Task<IActionResult> Cursos(int cunId) => Ok((await _service.Cursos(cunId)).Data);

        /// <summary>¿Hay un aspirante abierto igual en ese año? ¿La identidad ya es de un alumno?</summary>
        [HttpGet]
        [Route("DuplicadoAsync")]
        public async Task<IActionResult> Duplicado(int aniId, string? identidad, string? nombres, string? apellidos,
                                                   DateTime? fechaNacimiento, int? aspId) =>
            Ok((await _service.Duplicado(aniId, identidad, nombres, apellidos, fechaNacimiento, aspId)).Data);

        [HttpPost]
        [Route("GuardarAsync")]
        public async Task<IActionResult> Guardar([FromBody] AspiranteGuardarDTO obj)
        {
            Answer answer = await _service.Guardar(obj);
            if (answer.Access || answer.Data is not PR_tbAspirantes_GuardarResult r)
                return Ok(Fallo(answer, "No se pudo guardar el aspirante."));
            return Ok(new
            {
                Ok = true, Id = r.Asp_Id, Estado = r.Asp_Estado, Posicion = r.Asp_Posicion, r.PosicionCola, r.EnCola,
                Grado = r.Cun_Descripcion, AluId = (int?)null, r.Aviso, Mensaje = (string?)null
            });
        }

        /// <summary>ofrecer | rechazar | desistio | reactivar.</summary>
        [HttpPost]
        [Route("CambiarEstadoAsync")]
        public async Task<IActionResult> CambiarEstado([FromBody] AspiranteEstadoDTO obj)
        {
            Answer answer = await _service.CambiarEstado(obj);
            if (answer.Access || answer.Data is not PR_tbAspirantes_CambiarEstadoResult r)
                return Ok(Fallo(answer, "No se pudo cambiar el estado del aspirante."));
            return Ok(new
            {
                Ok = true, Id = r.Asp_Id, Estado = r.Asp_Estado, Posicion = r.Asp_Posicion, PosicionCola = (long?)null, EnCola = 0,
                Grado = (string?)null, AluId = r.Alu_Id, r.Aviso, Mensaje = (string?)null
            });
        }

        /// <summary>El wizard de Matrícula creó al alumno: el aspirante (con oferta) pasa a Matriculado.</summary>
        [HttpPost]
        [Route("MatricularAsync")]
        public async Task<IActionResult> Matricular([FromBody] AspiranteMatricularDTO obj)
        {
            Answer answer = await _service.Matricular(obj);
            if (answer.Access || answer.Data is not PR_tbAspirantes_CambiarEstadoResult r)
                return Ok(Fallo(answer, "No se pudo marcar al aspirante como matriculado."));
            return Ok(new
            {
                Ok = true, Id = r.Asp_Id, Estado = r.Asp_Estado, Posicion = r.Asp_Posicion, PosicionCola = (long?)null, EnCola = 0,
                Grado = (string?)null, AluId = r.Alu_Id, r.Aviso, Mensaje = (string?)null
            });
        }
    }
}
