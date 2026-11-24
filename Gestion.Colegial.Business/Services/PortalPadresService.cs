using Gestion.Colegial.Business.Extensions;
using Gestion.Colegial.Business.Interfaces;
using Gestion.Colegial.DataAccess.Interfaces;
using Gestion.Colegial.Entities;
using Gestion.Colegial.Entities.DTOs;
using Gestion.Colegial.Entities.Entities;
using System.Security.Cryptography;
using System.Text;
using System.Text.RegularExpressions;

namespace Gestion.Colegial.Business.Services
{
    /// <summary>
    /// Portal de padres (espejo de Skuul: portal de familias, invitaciones de cuenta y solicitudes).
    /// Cada lectura de la familia recibe el usuario firmado; el procedimiento resuelve su encargado y
    /// solo devuelve lo de sus hijos. Para reutilizar lecturas que ya existían (estado de cuenta,
    /// calendario del alumno) primero se comprueba que el alumno sea hijo del encargado.
    /// El código de la invitación se genera aquí y en la base solo queda su huella SHA-256.
    /// </summary>
    public class PortalPadresService : IPortalPadresService
    {
        public static readonly string[] Tipos = { "justificar", "cita", "constancia", "otro" };
        public static readonly string[] EstadosBandeja = { "nueva", "en_proceso", "atendida", "rechazada", "retirada", "abiertas" };
        public static readonly string[] EstadosAcceso = { "activo", "suspendido", "pendiente", "vencida", "revocada", "sin_invitar" };
        private const int HorasInvitacion = 72;
        private static readonly Regex Codigo = new Regex(@"^[0-9a-fA-F]{64}$");
        private static readonly Regex Letra = new Regex(@"\p{L}");
        private static readonly Regex Digito = new Regex(@"\d");

        private readonly IPortalPadresRepository _repository;
        private readonly IEstadoCuentaService _estadoCuenta;
        private readonly IEventosCalendarioService _calendario;
        private readonly ICentroAnunciosService _anuncios;

        public PortalPadresService(IPortalPadresRepository repository, IEstadoCuentaService estadoCuenta,
            IEventosCalendarioService calendario, ICentroAnunciosService anuncios)
        {
            _repository = repository;
            _estadoCuenta = estadoCuenta;
            _calendario = calendario;
            _anuncios = anuncios;
        }

        private static Answer Revisar(Answer answer)
        {
            if (answer.Access)
            {
                answer.Message = MessageShow.Error;
                Logs.Error(answer);
            }
            return answer;
        }

        private static Answer Rechazo(string mensaje) => new Answer { Access = true, Message = mensaje, Data = "" };

        /// <summary>Un error de validación del procedimiento (THROW 50000-50099) llega tal cual; otro se registra y se generaliza.</summary>
        private static Answer Escritura(Answer answer, string general)
        {
            if (answer.Access)
            {
                string? validacion = EventosCalendarioService.MensajeDeValidacionSql(answer);
                if (validacion == null) Logs.Error(answer);
                answer.Message = validacion ?? general;
            }
            return answer;
        }

        private static string Huella(string texto) =>
            Convert.ToHexString(SHA256.HashData(Encoding.UTF8.GetBytes(texto))).ToLowerInvariant();

        /// <summary>32 bytes al azar en hexadecimal: el enlace no distingue mayúsculas (las URLs del ADM van en minúsculas).</summary>
        private static string NuevoCodigo() =>
            Convert.ToHexString(RandomNumberGenerator.GetBytes(32)).ToLowerInvariant();

        private async Task<bool> PuedeVer(int usuId, int aluId)
        {
            if (usuId <= 0 || aluId <= 0) return false;
            Answer answer = await _repository.PuedeVer(usuId, aluId);
            return !answer.Access && answer.Data is PR_Portal_PuedeVerResult r && r.Puede;
        }

        // ── Familia ──
        public async Task<Answer> Encargado(int usuId) => Revisar(await _repository.Encargado(usuId));

        public async Task<Answer> Hijos(int usuId) => Revisar(await _repository.Hijos(usuId));

        public async Task<Answer> Notas(int usuId, int aluId, int? anio) => Revisar(await _repository.Notas(usuId, aluId, anio));

        public async Task<Answer> Asistencia(int usuId, int aluId, int? anio) => Revisar(await _repository.Asistencia(usuId, aluId, anio));

        public async Task<Answer> Cuenta(int usuId, int aluId, int? anio)
        {
            if (!await PuedeVer(usuId, aluId)) return Rechazo("No puede ver este alumno.");
            return await _estadoCuenta.Find(aluId, anio);
        }

        public async Task<Answer> Calendario(int usuId, int aluId, DateTime desde, DateTime hasta)
        {
            if (!await PuedeVer(usuId, aluId)) return Rechazo("No puede ver este alumno.");
            if (hasta < desde || (hasta - desde).TotalDays > 400) return Rechazo("El rango de fechas no es válido.");
            return await _calendario.ParaAlumno(aluId, desde, hasta);
        }

        public async Task<Answer> Anuncios(int usuId) => await _anuncios.ParaFamilia(usuId);

        public async Task<Answer> Solicitudes(int usuId, int? aluId) => Revisar(await _repository.Solicitudes(usuId, aluId));

        public async Task<Answer> SolicitudCrear(PortalSolicitudCrearDTO obj)
        {
            if (obj.Usuario is not > 0) return Rechazo("Esta acción necesita el usuario de la sesión.");
            if (string.IsNullOrWhiteSpace(obj.Tipo) || !Tipos.Contains(obj.Tipo)) return Rechazo("Elija qué tipo de solicitud quiere hacer.");
            if (string.IsNullOrWhiteSpace(obj.Asunto)) return Rechazo("Escriba un asunto corto para su solicitud.");
            if (obj.Asunto.Trim().Length > 150) return Rechazo("El asunto puede tener hasta 150 letras.");
            if (obj.Detalle != null && obj.Detalle.Trim().Length > 2000) return Rechazo("El detalle puede tener hasta 2000 letras.");
            return Escritura(await _repository.SolicitudCrear(obj), "No se pudo enviar la solicitud.");
        }

        public async Task<Answer> SolicitudRetirar(PortalSolicitudRetirarDTO obj)
        {
            if (obj.Usuario is not > 0) return Rechazo("Esta acción necesita el usuario de la sesión.");
            return Escritura(await _repository.SolicitudRetirar(obj), "No se pudo retirar la solicitud.");
        }

        // ── Bandeja del colegio ──
        public async Task<Answer> Bandeja(string? estado, string? tipo, string? texto)
        {
            if (!string.IsNullOrWhiteSpace(estado) && !EstadosBandeja.Contains(estado)) estado = null;
            if (!string.IsNullOrWhiteSpace(tipo) && !Tipos.Contains(tipo)) tipo = null;
            return Revisar(await _repository.Bandeja(estado, tipo, texto?.Length > 100 ? texto[..100] : texto));
        }

        public async Task<Answer> BandejaResumen() => Revisar(await _repository.BandejaResumen());

        public async Task<Answer> BandejaFind(int solId) => Revisar(await _repository.BandejaFind(solId));

        public async Task<Answer> BandejaHistorial(int solId) => Revisar(await _repository.BandejaHistorial(solId));

        public async Task<Answer> BandejaCambiar(PortalBandejaCambiarDTO obj)
        {
            if (obj.Usuario is not > 0) return Rechazo("Esta acción necesita el usuario de la sesión.");
            if (obj.Respuesta != null && obj.Respuesta.Trim().Length > 2000) return Rechazo("La respuesta puede tener hasta 2000 letras.");
            return Escritura(await _repository.BandejaCambiar(obj), "No se pudo cambiar la solicitud.");
        }

        // ── Invitaciones ──
        public async Task<Answer> Invitaciones(string? texto, string? estado, bool soloConHijos)
        {
            if (!string.IsNullOrWhiteSpace(estado) && !EstadosAcceso.Contains(estado)) estado = null;
            return Revisar(await _repository.Invitaciones(texto?.Length > 100 ? texto[..100] : texto, estado, soloConHijos));
        }

        public async Task<Answer> InvitacionesResumen() => Revisar(await _repository.InvitacionesResumen());

        public async Task<(Answer Answer, string? Codigo)> InvitacionCrear(PortalInvitacionAccionDTO obj)
        {
            if (obj.Usuario is not > 0) return (Rechazo("Esta acción necesita el usuario de la sesión."), null);
            string codigo = NuevoCodigo();
            Answer answer = Escritura(await _repository.InvitacionCrear(obj.Usuario.Value, obj.Enc_Id, Huella(codigo), HorasInvitacion),
                "No se pudo generar la invitación.");
            return (answer, answer.Access ? null : codigo);
        }

        public async Task<Answer> InvitacionRevocar(PortalInvitacionAccionDTO obj)
        {
            if (obj.Usuario is not > 0) return Rechazo("Esta acción necesita el usuario de la sesión.");
            return Escritura(await _repository.InvitacionRevocar(obj.Usuario.Value, obj.Enc_Id), "No se pudo detener la invitación.");
        }

        public async Task<Answer> AccesoCambiar(PortalInvitacionAccionDTO obj)
        {
            if (obj.Usuario is not > 0) return Rechazo("Esta acción necesita el usuario de la sesión.");
            return Escritura(await _repository.AccesoCambiar(obj.Usuario.Value, obj.Enc_Id, obj.Suspender), "No se pudo cambiar el acceso.");
        }

        public async Task<Answer> InvitacionInfo(string? codigo)
        {
            if (string.IsNullOrWhiteSpace(codigo) || !Codigo.IsMatch(codigo))
                return new Answer { Access = false, Data = new PR_Portal_InvitacionInfoResult { Estado = "no_existe" } };
            return Revisar(await _repository.InvitacionInfo(Huella(codigo.ToLowerInvariant())));
        }

        /// <summary>Misma huella que el login (SHA-256 en hexadecimal) y una contraseña mínima razonable.</summary>
        public async Task<Answer> InvitacionAceptar(PortalActivarDTO obj)
        {
            if (string.IsNullOrWhiteSpace(obj.Token) || !Codigo.IsMatch(obj.Token))
                return Rechazo("Este enlace de invitación ya no es válido. Pida uno nuevo al colegio.");
            string clave = obj.Contrasena ?? "";
            if (clave.Length < 8 || clave.Length > 100 || !Letra.IsMatch(clave) || !Digito.IsMatch(clave))
                return Rechazo("La contraseña debe tener al menos 8 caracteres, con letras y números.");
            if (string.IsNullOrWhiteSpace(obj.Usu_Name) || obj.Usu_Name.Trim().Length > 50)
                return Rechazo("Escriba un nombre de usuario de hasta 50 caracteres.");
            return Escritura(await _repository.InvitacionAceptar(Huella(obj.Token.ToLowerInvariant()), obj.Usu_Name.Trim(), Huella(clave)),
                "No se pudo activar la cuenta.");
        }
    }
}
