using Gestion.Colegial.Api.Seguridad;
using Gestion.Colegial.Business.Interfaces;
using Gestion.Colegial.Entities;
using Gestion.Colegial.Entities.DTOs;
using Gestion.Colegial.Entities.Entities;
using Microsoft.AspNetCore.Mvc;

namespace Gestion.Colegial.Api.Controllers
{
    /// <summary>
    /// Conexión con el año lectivo: cupos de las secciones del año, años donde se puede inscribir,
    /// inscripción de un alumno en un año, paso de la ubicación al abrir el año y semestres desde
    /// los períodos del año. Las escrituras responden { Ok, Mensaje, ... }.
    /// </summary>
    [ApiController]
    [Route("api/v1/[controller]")]
    [DatoDelServidor(DatoUsuario.Usuario, "Usuario")]
    public class AnioConexionController : ControllerBase
    {
        private readonly IAnioConexionService _service;

        public AnioConexionController(IAnioConexionService service)
        {
            _service = service;
        }

        private static object Fallo(Answer answer, string general) => new { Ok = false, Mensaje = answer.Message ?? general };

        [HttpGet]
        [Route("CuposAsync")]
        public async Task<IActionResult> Cupos(int aniId)
        {
            Answer answer = await _service.Cupos(aniId);
            return Ok(answer.Data);
        }

        [HttpPost]
        [Route("ActualizarCupoAsync")]
        [RequierePantalla("Editar cupos del año")]
        public async Task<IActionResult> ActualizarCupo([FromBody] CupoSeccionDTO obj)
        {
            Answer answer = await _service.ActualizarCupo(obj);
            if (answer.Access || answer.Data is not PR_tbSeccionesAnio_ActualizarCupoResult r)
                return Ok(Fallo(answer, "No se pudo cambiar el cupo."));
            return Ok(new { Ok = true, Mensaje = (string?)null, r.Sea_Id, r.Sea_Cupo, r.Inscritos, r.Libres });
        }

        [HttpGet]
        [Route("AniosInscripcionAsync")]
        public async Task<IActionResult> AniosInscripcion()
        {
            Answer answer = await _service.AniosInscripcion();
            return Ok(answer.Data);
        }

        [HttpGet]
        [Route("VerificarCupoAsync")]
        public async Task<IActionResult> VerificarCupo(int? aniId, int nivId, int cunId, int? mdaId, int secId)
        {
            Answer answer = await _service.VerificarCupo(aniId, nivId, cunId, mdaId, secId);
            return Ok(answer.Data);
        }

        [HttpPost]
        [Route("InscribirAlumnoAsync")]
        [RequierePantalla("Matrícula nueva|Re-matrícula|Promociones y expediente por año")]
        public async Task<IActionResult> InscribirAlumno([FromBody] InscribirAlumnoDTO obj)
        {
            Answer answer = await _service.InscribirAlumno(obj);
            if (answer.Access || answer.Data is not PR_AnioConexion_InscribirAlumnoResult r)
                return Ok(Fallo(answer, "No se pudo inscribir al alumno en el año."));
            return Ok(new { Ok = true, Mensaje = (string?)null, r.Mta_Id, r.Sea_Id, r.Sea_Nombre, r.Ani_Nombre, r.Cupo, r.Inscritos });
        }

        [HttpPost]
        [Route("AplicarUbicacionAsync")]
        [RequierePantalla("Listado de años lectivos")]
        public async Task<IActionResult> AplicarUbicacion([FromBody] AplicarUbicacionDTO obj)
        {
            Answer answer = await _service.AplicarUbicacion(obj);
            if (answer.Access || answer.Data is not PR_tbAnioLectivo_AplicarUbicacionResult r)
                return Ok(Fallo(answer, "No se pudo pasar la ubicación de los alumnos al año."));
            return Ok(new { Ok = true, Mensaje = (string?)null, r.Aplicados, r.CursoPorRevisar });
        }

        [HttpGet]
        [Route("UbicacionPreviaAsync")]
        [RequierePantalla("Listado de años lectivos")]
        public async Task<IActionResult> UbicacionPrevia(int aniId)
        {
            Answer answer = await _service.UbicacionPrevia(aniId);
            if (answer.Access || answer.Data is not PR_tbAnioLectivo_UbicacionPreviaResult r)
                return Ok(Fallo(answer, "No se pudo calcular la vista previa."));
            return Ok(new { Ok = true, Mensaje = (string?)null, r.Mover, r.CursoPorRevisar, r.NoActivos });
        }

        [HttpGet]
        [Route("SemestresAsync")]
        public async Task<IActionResult> Semestres(int anio)
        {
            Answer answer = await _service.Semestres(anio);
            return Ok(answer.Data);
        }
    }
}
