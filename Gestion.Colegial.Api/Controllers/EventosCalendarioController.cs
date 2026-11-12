using Gestion.Colegial.Business.Interfaces;
using Gestion.Colegial.Entities;
using Gestion.Colegial.Entities.DTOs;
using Microsoft.AspNetCore.Mvc;

namespace Gestion.Colegial.Api.Controllers
{
    /// <summary>
    /// Calendario escolar (espejo de Skuul "Calendar"): feriados, cierres, actos, reuniones, citas
    /// y exámenes; "Para quién" por sección del año, rol o persona; borrador / publicado.
    /// Un Feriado o Cierre publicado cierra el colegio: ese día la sección no tiene pase de lista.
    /// Fechas en formato yyyy-MM-dd.
    /// </summary>
    [ApiController]
    [Route("api/v1/[controller]")]
    public class EventosCalendarioController : ControllerBase
    {
        private readonly IEventosCalendarioService _service;

        public EventosCalendarioController(IEventosCalendarioService service)
        {
            _service = service;
        }

        /// <summary>
        /// Días que tocan el rango (vista de mes). incluirBorradores = false para quien solo lee.
        /// verTodo = true (quien edita): todo. Si no: lo de todo el colegio + lo que es para la persona
        /// (empId: el empleado y sus secciones; rolId: su rol).
        /// </summary>
        [HttpGet]
        [Route("ListRangoAsync")]
        public async Task<IActionResult> ListRango(DateTime desde, DateTime hasta, bool incluirBorradores = true,
                                                   bool verTodo = true, int? empId = null, int? rolId = null)
        {
            Answer answer = await _service.ListRango(desde, hasta, incluirBorradores, verTodo, empId, rolId);
            return Ok(answer.Data);
        }

        /// <summary>Un día. Con verTodo = false solo si está publicado y es para la persona; si no, respuesta vacía.</summary>
        [HttpGet]
        [Route("FindAsync")]
        public async Task<IActionResult> Find(int value, bool verTodo = true, int? empId = null, int? rolId = null)
        {
            Answer answer = await _service.Find(value, verTodo, empId, rolId);
            return Ok(answer.Data);
        }

        /// <summary>"Para quién" de un día (secciones, roles, empleados, alumnos).</summary>
        [HttpGet]
        [Route("AudienciaAsync")]
        public async Task<IActionResult> Audiencia(int value)
        {
            Answer answer = await _service.Audiencia(value);
            return Ok(answer.Data);
        }

        /// <summary>Borradores por mes: [{ Mes: "yyyy-MM", Borradores }]; lista vacía si no hay.</summary>
        [HttpGet]
        [Route("BorradoresAsync")]
        public async Task<IActionResult> Borradores()
        {
            Answer answer = await _service.Borradores();
            return Ok(answer.Data);
        }

        /// <summary>¿Cierra el colegio ese día para la sección del año (seaId) o la del horario (horId)?</summary>
        [HttpGet]
        [Route("CierreEnFechaAsync")]
        public async Task<IActionResult> CierreEnFecha(DateTime fecha, int? seaId, int? horId)
        {
            Answer answer = await _service.CierreEnFecha(fecha, seaId, horId);
            return Ok(answer.Data);
        }

        /// <summary>Hoy y los próximos días. verTodo = todo lo publicado; si no, lo de la persona (empleado/rol/secciones).</summary>
        [HttpGet]
        [Route("ProximosAsync")]
        public async Task<IActionResult> Proximos(DateTime? hoy, int dias = 7, bool verTodo = false, int? empId = null, int? rolId = null, int limite = 5)
        {
            Answer answer = await _service.Proximos(hoy, dias, verTodo, empId, rolId, limite);
            return Ok(answer.Data);
        }

        /// <summary>Calendario de un alumno (portal de padres): todo el colegio, su sección del año y él con nombre.</summary>
        [HttpGet]
        [Route("ParaAlumnoAsync")]
        public async Task<IActionResult> ParaAlumno(int aluId, DateTime desde, DateTime hasta)
        {
            Answer answer = await _service.ParaAlumno(aluId, desde, hasta);
            return Ok(answer.Data);
        }

        [HttpGet]
        [Route("SeccionesAudienciaAsync")]
        public async Task<IActionResult> SeccionesAudiencia(DateTime? fecha, int? eveId)
        {
            Answer answer = await _service.SeccionesAudiencia(fecha, eveId);
            return Ok(answer.Data);
        }

        [HttpGet]
        [Route("RolesAudienciaAsync")]
        public async Task<IActionResult> RolesAudiencia()
        {
            Answer answer = await _service.RolesAudiencia();
            return Ok(answer.Data);
        }

        [HttpGet]
        [Route("BuscarPersonasAsync")]
        public async Task<IActionResult> BuscarPersonas(string texto, int limite = 8)
        {
            Answer answer = await _service.BuscarPersonas(texto, limite);
            return Ok(answer.Data);
        }

        /// <summary>
        /// Crea (Eve_Id = 0, nace borrador) o cambia un día. Siempre responde { Eve_Id, Creado, Mensaje }.
        /// Si no se guardó, Eve_Id = 0 y Mensaje trae el motivo (validación propia o del procedimiento).
        /// </summary>
        [HttpPost]
        [Route("GuardarAsync")]
        public async Task<IActionResult> Guardar([FromBody] EventoCalendarioGuardarDTO obj)
        {
            Answer answer = await _service.Guardar(obj);
            if (answer.Access || answer.Data is not Entities.Entities.PR_tbEventosCalendario_GuardarResult r)
                return Ok(new { Eve_Id = 0, Creado = false, Mensaje = answer.Message ?? "No se pudo guardar el día en el calendario." });
            return Ok(new { r.Eve_Id, r.Creado, Mensaje = (string?)null });
        }

        /// <summary>publicar = true lo publica; false lo vuelve borrador.</summary>
        [HttpPost]
        [Route("PublicarAsync")]
        public async Task<IActionResult> Publicar(int id, bool publicar = true, int? usuario = null)
        {
            Answer answer = await _service.Publicar(id, publicar, usuario);
            return Ok(answer.Data);
        }

        /// <summary>Quita un día del calendario (baja lógica). Devuelve el mes para volver a él.</summary>
        [HttpPost]
        [Route("EliminarAsync")]
        public async Task<IActionResult> Eliminar(int id, int? usuario = null)
        {
            Answer answer = await _service.Eliminar(id, usuario);
            return Ok(answer.Data);
        }

        /// <summary>Feriados y fechas escolares de Honduras propuestos para el año, con lo ya cargado.</summary>
        [HttpGet]
        [Route("FeriadosHondurasAsync")]
        public async Task<IActionResult> FeriadosHonduras(int anio)
        {
            Answer answer = await _service.FeriadosHonduras(anio);
            return Ok(answer.Data);
        }

        /// <summary>
        /// Carga los feriados elegidos (no duplica los ya cargados). Siempre responde { Creados, YaEstaban, Mensaje };
        /// Mensaje = null si todo salió bien, o qué faltó si la carga falló a medias.
        /// </summary>
        [HttpPost]
        [Route("CargarFeriadosHondurasAsync")]
        public async Task<IActionResult> CargarFeriadosHonduras([FromBody] CargarFeriadosDTO obj)
        {
            Answer answer = await _service.CargarFeriadosHonduras(obj);
            return Ok(answer.Data);
        }
    }
}
