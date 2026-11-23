using Gestion.Colegial.Api.Seguridad;
using Gestion.Colegial.Business.Interfaces;
using Gestion.Colegial.Entities;
using Gestion.Colegial.Entities.DTOs;
using Gestion.Colegial.Entities.Entities;
using Microsoft.AspNetCore.Mvc;

namespace Gestion.Colegial.Api.Controllers
{
    /// <summary>
    /// Centro de reportes: reportes que no existían (lista de clase, saldos por alumno, ingresos por
    /// concepto, asistencia del personal) y el registro de reportes generados ("Recientes").
    /// Quién puede ver cada reporte lo decide el ADM con los permisos de la sesión.
    /// Si una lectura falla se responde 500, para que el ADM la registre como fallida.
    /// </summary>
    [ApiController]
    [Route("api/v1/[controller]")]
    [DatoDelServidor(DatoUsuario.Usuario, "usuId", "Usu_Id")]
    public class CentroReportesController : ControllerBase
    {
        private readonly ICentroReportesService _service;

        public CentroReportesController(ICentroReportesService service)
        {
            _service = service;
        }

        private IActionResult Lista(Answer answer) =>
            answer.Access || answer.Data is string
                ? StatusCode(500, answer.Message ?? "No se pudo generar el reporte.")
                : Ok(answer.Data);

        [HttpGet]
        [Route("ListaClaseAsync")]
        public async Task<IActionResult> ListaClase(int aniId, int? nivId = null, int? cunId = null, int? seaId = null,
                                                    bool soloActivos = true, DateTime? hoy = null) =>
            Lista(await _service.ListaClase(aniId, nivId, cunId, seaId, soloActivos, hoy ?? DateTime.Today));

        [HttpGet]
        [Route("SaldosAlumnoAsync")]
        public async Task<IActionResult> SaldosAlumno(int aniId, int? nivId = null, int? cunId = null, int? seaId = null,
                                                      bool soloConSaldo = true, DateTime? hoy = null) =>
            Lista(await _service.SaldosAlumno(aniId, nivId, cunId, seaId, soloConSaldo, hoy ?? DateTime.Today));

        [HttpGet]
        [Route("IngresosConceptoAsync")]
        public async Task<IActionResult> IngresosConcepto(DateTime desde, DateTime hasta, int? cpaId = null, int? fpaId = null) =>
            Lista(await _service.IngresosConcepto(desde, hasta, cpaId, fpaId));

        [HttpGet]
        [Route("AsistenciaPersonalAsync")]
        public async Task<IActionResult> AsistenciaPersonal(DateTime desde, DateTime hasta) =>
            Lista(await _service.AsistenciaPersonal(desde, hasta));

        [HttpGet]
        [Route("RecientesAsync")]
        public async Task<IActionResult> Recientes(int usuId, int top = 30) =>
            Lista(await _service.Recientes(usuId, top));

        [HttpPost]
        [Route("RegistrarAsync")]
        public async Task<IActionResult> Registrar([FromBody] ReporteGeneradoDTO obj)
        {
            Answer answer = await _service.Registrar(obj);
            if (answer.Access || answer.Data is not PR_tbReportesGenerados_RegistrarResult r)
                return BadRequest(answer.Message ?? "No se pudo registrar el reporte.");
            return Ok(new { Ok = true, Id = r.Rge_Id });
        }
    }
}
