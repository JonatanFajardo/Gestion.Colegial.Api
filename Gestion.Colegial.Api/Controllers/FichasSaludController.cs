using Gestion.Colegial.Business.Interfaces;
using Gestion.Colegial.Entities;
using Gestion.Colegial.Entities.DTOs;
using Gestion.Colegial.Entities.Entities;
using Microsoft.AspNetCore.Mvc;
using Gestion.Colegial.Api.Seguridad;

namespace Gestion.Colegial.Api.Controllers
{
    /// <summary>
    /// Ficha de salud del alumno (espejo de Skuul "health records"): directorio con filtros, la ficha,
    /// a quién llamar (encargados con teléfono), historial de cambios y las alertas críticas de la
    /// sección de un horario para el pase de lista.
    /// Guardar responde siempre { Ok, Id, Version, Accion, Campos, Mensaje }.
    /// </summary>
    [ApiController]
    [Route("api/v1/[controller]")]
    [DatoDelServidor(DatoUsuario.Usuario, "Usuario")]
    public class FichasSaludController : ControllerBase
    {
        private readonly IFichasSaludService _service;

        public FichasSaludController(IFichasSaludService service)
        {
            _service = service;
        }

        /// <summary>Alumnos activos con el estado de su ficha. Todos los filtros son opcionales.</summary>
        [HttpGet]
        [Route("DirectorioAsync")]
        public async Task<IActionResult> Directorio(int? nivId = null, int? cunId = null, int? secId = null, string? texto = null,
                                                    bool soloSinFicha = false, bool soloConAlerta = false)
        {
            Answer answer = await _service.Directorio(nivId, cunId, secId, texto, soloSinFicha, soloConAlerta);
            return Ok(answer.Data);
        }

        /// <summary>El alumno y su ficha (campos de la ficha en null si no tiene). Vacío si el alumno no existe.</summary>
        [HttpGet]
        [Route("FindAsync")]
        public async Task<IActionResult> Find(int value)
        {
            Answer answer = await _service.Find(value);
            return Ok(answer.Data);
        }

        /// <summary>Encargados del alumno con su teléfono, el principal primero.</summary>
        [HttpGet]
        [Route("ContactosAsync")]
        public async Task<IActionResult> Contactos(int value) => Ok((await _service.Contactos(value)).Data);

        /// <summary>Historial de cambios de la ficha (qué campos, quién y cuándo; sin valores).</summary>
        [HttpGet]
        [Route("BitacoraAsync")]
        public async Task<IActionResult> Bitacora(int value) => Ok((await _service.Bitacora(value)).Data);

        /// <summary>
        /// Alertas críticas de los alumnos del pase de lista de un horario: solo Alu_Id y Fsa_Alerta.
        /// Solo las recibe quien puede pasar lista de ese horario ese día (dirección, titular o suplente).
        /// </summary>
        [HttpGet]
        [Route("AlertasSeccionAsync")]
        public async Task<IActionResult> AlertasSeccion(int horId, DateTime? fecha = null, int? usuarioId = null) =>
            Ok((await _service.AlertasSeccion(horId, fecha, usuarioId)).Data);

        [HttpPost]
        [Route("GuardarAsync")]
        [RequierePantalla("Editar ficha de salud")]
        public async Task<IActionResult> Guardar([FromBody] FichaSaludGuardarDTO obj)
        {
            Answer answer = await _service.Guardar(obj);
            if (answer.Access || answer.Data is not PR_tbFichasSalud_GuardarResult r)
                return Ok(new { Ok = false, Id = 0, Version = 0, Accion = (string?)null, Campos = (string?)null,
                                Mensaje = answer.Message ?? "No se pudo guardar la ficha de salud." });
            return Ok(new { Ok = true, Id = r.Fsa_Id, Version = r.Fsa_Version, Accion = r.Accion, Campos = r.Campos, Mensaje = (string?)null });
        }
    }
}
