using Gestion.Colegial.Business.Interfaces;
using Gestion.Colegial.Business.Services;
using Gestion.Colegial.Entities;
using Gestion.Colegial.Entities.DTOs;
using Microsoft.AspNetCore.Mvc;
using Gestion.Colegial.Api.Seguridad;

namespace Gestion.Colegial.Api.Controllers
{
    /// <summary>
    /// Notas ponderadas (script 089): plantillas de evaluación con pesos por tipo (Dirección) y actividades del
    /// cuaderno de notas con sus puntos (docente). Cada pedido trae el usuario (usuId o Usuario): el procedimiento
    /// decide qué puede ver y hacer. Las escrituras responden
    /// { Ok, Id, Cev_Id, Version, Cantidad, Omitidas, Sincronizados, Conservados, NotasEscritas, NotasFallidas, AvisoNotas, Mensaje }.
    /// </summary>
    [ApiController]
    [Route("api/v1/[controller]")]
    [DatoDelServidor(DatoUsuario.Usuario, "usuId", "Usuario")]
    public class EvaluacionesController : ControllerBase
    {
        private const string PantallaCuaderno = "Cuaderno de notas";
        private const string PantallaPlantillas = "Plantillas de evaluación";

        private readonly IEvaluacionesService _service;

        public EvaluacionesController(IEvaluacionesService service)
        {
            _service = service;
        }

        private static object Lista(Answer answer) => answer.Access || answer.Data is string ? Array.Empty<object>() : answer.Data;

        private IActionResult Escritura(Answer answer, string general)
        {
            if (answer.Access || answer.Data is not EvaluacionEscrituraRespuesta r)
                return Ok(new { Ok = false, Id = 0, Mensaje = answer.Message ?? general });
            return Ok(new
            {
                Ok = true, r.Id, r.Cev_Id, r.Version, r.Cantidad, r.Omitidas, r.Sincronizados, r.Conservados,
                r.NotasEscritas, r.NotasFallidas, r.AvisoNotas, Mensaje = (string?)null
            });
        }

        /// <summary>Todo el cuaderno de un horario y parcial en un JSON; { Error, Message } si no se puede ver.</summary>
        [HttpGet]
        [Route("CuadernoAsync")]
        [RequierePantalla(PantallaCuaderno)]
        public async Task<IActionResult> Cuaderno(int horId, int pacId, int usuId)
        {
            Answer answer = await _service.Cuaderno(horId, pacId, usuId);
            if (answer.Access || answer.Data is not string json || json.Length == 0)
                return Ok(new { Error = true, Message = answer.Message ?? "No se pudo cargar el cuaderno de actividades." });
            return Content(json, "application/json");
        }

        [HttpPost]
        [Route("GuardarActividadAsync")]
        [RequierePantalla(PantallaCuaderno)]
        public async Task<IActionResult> GuardarActividad([FromBody] ActividadEvaluacionGuardarDTO obj) =>
            Escritura(await _service.GuardarActividad(obj), "No se pudo guardar la actividad.");

        [HttpPost]
        [Route("QuitarActividadAsync")]
        [RequierePantalla(PantallaCuaderno)]
        public async Task<IActionResult> QuitarActividad([FromBody] ActividadEvaluacionQuitarDTO obj) =>
            Escritura(await _service.QuitarActividad(obj), "No se pudo quitar la actividad.");

        [HttpPost]
        [Route("GuardarPuntosAsync")]
        [RequierePantalla(PantallaCuaderno)]
        public async Task<IActionResult> GuardarPuntos([FromBody] PuntosEvaluacionGuardarDTO obj) =>
            Escritura(await _service.GuardarPuntos(obj), "No se pudieron guardar los puntos.");

        /// <summary>Vuelve a pasar a app.tbNotas las notas calculadas del cuaderno.</summary>
        [HttpPost]
        [Route("ActualizarNotasAsync")]
        [RequierePantalla(PantallaCuaderno)]
        public async Task<IActionResult> ActualizarNotas(int cevId, int usuId) =>
            Escritura(await _service.ActualizarNotas(cevId, usuId), "No se pudieron actualizar las notas del parcial.");

        [HttpGet]
        [Route("PlantillasAsync")]
        [RequierePantalla(PantallaPlantillas)]
        public async Task<IActionResult> Plantillas(int anio, int usuId) => Ok(Lista(await _service.Plantillas(anio, usuId)));

        /// <summary>Opciones: tipo = anio | nivel | materia (del año y nivel, según el horario).</summary>
        [HttpGet]
        [Route("OpcionesAsync")]
        [RequierePantalla(PantallaPlantillas)]
        public async Task<IActionResult> Opciones(int usuId, string? tipo, int? anio = null, int? nivId = null) =>
            Ok(Lista(await _service.Opciones(usuId, tipo, anio, nivId)));

        [HttpPost]
        [Route("GuardarPlantillaAsync")]
        [RequierePantalla(PantallaPlantillas)]
        public async Task<IActionResult> GuardarPlantilla([FromBody] PlantillaEvaluacionGuardarDTO obj) =>
            Escritura(await _service.GuardarPlantilla(obj), "No se pudo guardar la plantilla.");

        [HttpPost]
        [Route("QuitarPlantillaAsync")]
        [RequierePantalla(PantallaPlantillas)]
        public async Task<IActionResult> QuitarPlantilla([FromBody] PlantillaEvaluacionQuitarDTO obj) =>
            Escritura(await _service.QuitarPlantilla(obj), "No se pudo quitar la plantilla.");

        /// <summary>Uso de las actividades por materia y sección en un parcial (Dirección).</summary>
        [HttpGet]
        [Route("AvanceAsync")]
        [RequierePantalla(PantallaPlantillas)]
        public async Task<IActionResult> Avance(int anio, int semId, int pacId, int usuId) =>
            Ok(Lista(await _service.Avance(anio, semId, pacId, usuId)));
    }
}
