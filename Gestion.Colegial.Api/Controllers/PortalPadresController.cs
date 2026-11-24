using Gestion.Colegial.Api.Seguridad;
using Gestion.Colegial.Business.Interfaces;
using Gestion.Colegial.Entities;
using Gestion.Colegial.Entities.DTOs;
using Gestion.Colegial.Entities.Entities;
using Microsoft.AspNetCore.Mvc;

namespace Gestion.Colegial.Api.Controllers
{
    /// <summary>
    /// Portal de padres (script 082), espejo de Skuul: lo que ve la familia de cada hijo, sus
    /// solicitudes, la bandeja de Secretaría y las invitaciones de cuenta.
    /// - Familia ("Portal de padres"): el usuario (usuId / Usuario) lo pone el servidor con el usuario
    ///   firmado; el encargado sale de ese usuario y solo se leen sus hijos.
    /// - Bandeja ("Solicitudes del portal") e invitaciones ("Invitaciones al portal"): exigen la pantalla.
    /// - InvitacionAsync y ActivarAsync son públicas (solo la llave): las usa la página de activación.
    /// Las escrituras responden { Ok, Id, Estado, Mensaje }.
    /// </summary>
    [ApiController]
    [Route("api/v1/[controller]")]
    [DatoDelServidor(DatoUsuario.Usuario, "usuId", "Usuario")]
    public class PortalPadresController : ControllerBase
    {
        private const string Portal = "Portal de padres";
        private const string Bandeja_ = "Solicitudes del portal";
        private const string Invitaciones_ = "Invitaciones al portal";

        private readonly IPortalPadresService _service;

        public PortalPadresController(IPortalPadresService service)
        {
            _service = service;
        }

        private static object Lista(Answer answer) => answer.Access || answer.Data is string || answer.Data == null ? Array.Empty<object>() : answer.Data;
        private static object? Uno(Answer answer) => answer.Access || answer.Data is string ? null : answer.Data;

        private static object Fallo(Answer answer, string general) =>
            new { Ok = false, Id = 0, Estado = (string?)null, Mensaje = answer.Message ?? general };

        private static object Resultado(Answer answer, string general) =>
            answer.Access || answer.Data is not PR_Portal_SolicitudEscrituraResult r
                ? Fallo(answer, general)
                : new { Ok = true, Id = r.Sol_Id, Estado = (string?)r.Sol_Estado, Mensaje = (string?)null };

        // ───────────── Familia ─────────────
        [HttpGet("EncargadoAsync")]
        [RequierePantalla(Portal)]
        public async Task<IActionResult> Encargado(int? usuId) =>
            Ok(usuId is > 0 ? Uno(await _service.Encargado(usuId.Value)) : null);

        [HttpGet("HijosAsync")]
        [RequierePantalla(Portal)]
        public async Task<IActionResult> Hijos(int? usuId) =>
            Ok(usuId is > 0 ? Lista(await _service.Hijos(usuId.Value)) : Array.Empty<object>());

        [HttpGet("NotasAsync")]
        [RequierePantalla(Portal)]
        public async Task<IActionResult> Notas(int aluId, int? anio, int? usuId) =>
            Ok(usuId is > 0 ? Lista(await _service.Notas(usuId.Value, aluId, anio)) : Array.Empty<object>());

        [HttpGet("AsistenciaAsync")]
        [RequierePantalla(Portal)]
        public async Task<IActionResult> Asistencia(int aluId, int? anio, int? usuId) =>
            Ok(usuId is > 0 ? Lista(await _service.Asistencia(usuId.Value, aluId, anio)) : Array.Empty<object>());

        [HttpGet("CuentaAsync")]
        [RequierePantalla(Portal)]
        public async Task<IActionResult> Cuenta(int aluId, int? anio, int? usuId) =>
            Ok(usuId is > 0 ? Lista(await _service.Cuenta(usuId.Value, aluId, anio)) : Array.Empty<object>());

        [HttpGet("CalendarioAsync")]
        [RequierePantalla(Portal)]
        public async Task<IActionResult> Calendario(int aluId, DateTime desde, DateTime hasta, int? usuId) =>
            Ok(usuId is > 0 ? Lista(await _service.Calendario(usuId.Value, aluId, desde, hasta)) : Array.Empty<object>());

        [HttpGet("AnunciosAsync")]
        [RequierePantalla(Portal)]
        public async Task<IActionResult> Anuncios() => Ok(Lista(await _service.Anuncios()));

        [HttpGet("SolicitudesAsync")]
        [RequierePantalla(Portal)]
        public async Task<IActionResult> Solicitudes(int? aluId, int? usuId) =>
            Ok(usuId is > 0 ? Lista(await _service.Solicitudes(usuId.Value, aluId)) : Array.Empty<object>());

        [HttpPost("SolicitudCrearAsync")]
        [RequierePantalla(Portal)]
        public async Task<IActionResult> SolicitudCrear([FromBody] PortalSolicitudCrearDTO obj) =>
            Ok(Resultado(await _service.SolicitudCrear(obj), "No se pudo enviar la solicitud."));

        [HttpPost("SolicitudRetirarAsync")]
        [RequierePantalla(Portal)]
        public async Task<IActionResult> SolicitudRetirar([FromBody] PortalSolicitudRetirarDTO obj) =>
            Ok(Resultado(await _service.SolicitudRetirar(obj), "No se pudo retirar la solicitud."));

        // ───────────── Bandeja de solicitudes (colegio) ─────────────
        [HttpGet("BandejaAsync")]
        [RequierePantalla(Bandeja_)]
        public async Task<IActionResult> Bandeja(string? estado, string? tipo, string? texto) =>
            Ok(Lista(await _service.Bandeja(estado, tipo, texto)));

        [HttpGet("BandejaResumenAsync")]
        [RequierePantalla(Bandeja_)]
        public async Task<IActionResult> BandejaResumen() => Ok(Uno(await _service.BandejaResumen()));

        [HttpGet("BandejaFindAsync")]
        [RequierePantalla(Bandeja_)]
        public async Task<IActionResult> BandejaFind(int value) => Ok(Uno(await _service.BandejaFind(value)));

        [HttpGet("BandejaHistorialAsync")]
        [RequierePantalla(Bandeja_)]
        public async Task<IActionResult> BandejaHistorial(int value) => Ok(Lista(await _service.BandejaHistorial(value)));

        [HttpPost("BandejaCambiarAsync")]
        [RequierePantalla(Bandeja_)]
        public async Task<IActionResult> BandejaCambiar([FromBody] PortalBandejaCambiarDTO obj) =>
            Ok(Resultado(await _service.BandejaCambiar(obj), "No se pudo cambiar la solicitud."));

        // ───────────── Invitaciones al portal ─────────────
        [HttpGet("InvitacionesAsync")]
        [RequierePantalla(Invitaciones_)]
        public async Task<IActionResult> Invitaciones(string? texto, string? estado, bool soloConHijos = true) =>
            Ok(Lista(await _service.Invitaciones(texto, estado, soloConHijos)));

        [HttpGet("InvitacionesResumenAsync")]
        [RequierePantalla(Invitaciones_)]
        public async Task<IActionResult> InvitacionesResumen() => Ok(Uno(await _service.InvitacionesResumen()));

        /// <summary>Genera el enlace. El código en claro solo viaja en esta respuesta.</summary>
        [HttpPost("InvitarAsync")]
        [RequierePantalla(Invitaciones_)]
        public async Task<IActionResult> Invitar([FromBody] PortalInvitacionAccionDTO obj)
        {
            var (answer, codigo) = await _service.InvitacionCrear(obj);
            if (answer.Access || codigo == null || answer.Data is not PR_Portal_InvitacionCrearResult r)
                return Ok(new { Ok = false, Id = 0, Codigo = (string?)null, Vence = (DateTime?)null, Nombre = (string?)null, Mensaje = answer.Message ?? "No se pudo generar la invitación." });
            return Ok(new { Ok = true, Id = r.Inv_Id, Codigo = codigo, Vence = (DateTime?)r.Inv_Vence, Nombre = r.Enc_Nombre, Mensaje = (string?)null });
        }

        [HttpPost("RevocarAsync")]
        [RequierePantalla(Invitaciones_)]
        public async Task<IActionResult> Revocar([FromBody] PortalInvitacionAccionDTO obj)
        {
            Answer answer = await _service.InvitacionRevocar(obj);
            return Ok(answer.Access ? Fallo(answer, "No se pudo detener la invitación.") : new { Ok = true, Id = obj.Enc_Id, Estado = (string?)"revocada", Mensaje = (string?)null });
        }

        [HttpPost("AccesoAsync")]
        [RequierePantalla(Invitaciones_)]
        public async Task<IActionResult> Acceso([FromBody] PortalInvitacionAccionDTO obj)
        {
            Answer answer = await _service.AccesoCambiar(obj);
            return Ok(answer.Access ? Fallo(answer, "No se pudo cambiar el acceso.")
                : new { Ok = true, Id = obj.Enc_Id, Estado = (string?)(obj.Suspender ? "suspendido" : "activo"), Mensaje = (string?)null });
        }

        // ───────────── Activación pública (solo la llave) ─────────────
        [HttpGet("InvitacionAsync")]
        public async Task<IActionResult> Invitacion(string? codigo) =>
            Ok(Uno(await _service.InvitacionInfo(codigo)) ?? new PR_Portal_InvitacionInfoResult { Estado = "no_existe" });

        [HttpPost("ActivarAsync")]
        public async Task<IActionResult> Activar([FromBody] PortalActivarDTO obj)
        {
            Answer answer = await _service.InvitacionAceptar(obj);
            if (answer.Access || answer.Data is not PR_Portal_InvitacionAceptarResult r)
                return Ok(Fallo(answer, "No se pudo activar la cuenta."));
            return Ok(new { Ok = true, Id = r.Usu_Id, Estado = (string?)r.Usu_Name, Mensaje = (string?)null });
        }
    }
}
