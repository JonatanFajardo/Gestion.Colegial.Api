using Gestion.Colegial.DataAccess.Interfaces;
using Gestion.Colegial.Entities;
using Gestion.Colegial.Entities.DTOs;
using Gestion.Colegial.Entities.Entities;
using System.Data;
using System.Data.SqlClient;

namespace Gestion.Colegial.DataAccess.Repositories
{
    /// <summary>
    /// Portal de padres (script 082). Las lecturas de la familia reciben el usuario y el procedimiento
    /// las limita a los alumnos ligados a su encargado. Las escrituras devuelven una fila (Search):
    /// si el procedimiento lanza un error, queda en Answer y no se relanza.
    /// </summary>
    public class PortalPadresRepository : RepositoryBase, IPortalPadresRepository
    {
        private static SqlParameter Entero(string nombre, int? valor) =>
            new SqlParameter() { ParameterName = nombre, DbType = DbType.Int32, Value = (object?)valor ?? DBNull.Value };

        private static SqlParameter Booleano(string nombre, bool valor) =>
            new SqlParameter() { ParameterName = nombre, DbType = DbType.Boolean, Value = valor };

        private static SqlParameter Fecha(string nombre, DateTime? valor) =>
            new SqlParameter() { ParameterName = nombre, DbType = DbType.Date, Value = valor.HasValue ? valor.Value.Date : DBNull.Value };

        private static SqlParameter Texto(string nombre, string? valor, DbType tipo = DbType.String) =>
            new SqlParameter() { ParameterName = nombre, DbType = tipo, Value = string.IsNullOrWhiteSpace(valor) ? DBNull.Value : valor.Trim() };

        private static readonly SqlParameter[] SinParametros = Array.Empty<SqlParameter>();

        public async Task<Answer> Encargado(int usuId) =>
            await Search<PR_Portal_EncargadoResult>("app.PR_Portal_Encargado", new[] { Entero("@Usu_Id", usuId) });

        public async Task<Answer> Hijos(int usuId) =>
            await Read<PR_Portal_HijosResult>("app.PR_Portal_Hijos", new[] { Entero("@Usu_Id", usuId) });

        public async Task<Answer> PuedeVer(int usuId, int aluId) =>
            await Search<PR_Portal_PuedeVerResult>("app.PR_Portal_PuedeVer", new[] { Entero("@Usu_Id", usuId), Entero("@Alu_Id", aluId) });

        public async Task<Answer> Notas(int usuId, int aluId, int? anio) =>
            await Read<PR_Portal_NotasResult>("app.PR_Portal_Notas", new[] { Entero("@Usu_Id", usuId), Entero("@Alu_Id", aluId), Entero("@Anio", anio) });

        public async Task<Answer> Asistencia(int usuId, int aluId, int? anio) =>
            await Read<PR_Portal_AsistenciaResult>("app.PR_Portal_Asistencia", new[] { Entero("@Usu_Id", usuId), Entero("@Alu_Id", aluId), Entero("@Anio", anio) });

        public async Task<Answer> Solicitudes(int usuId, int? aluId) =>
            await Read<PR_Portal_SolicitudesResult>("app.PR_Portal_Solicitudes", new[] { Entero("@Usu_Id", usuId), Entero("@Alu_Id", aluId) });

        public async Task<Answer> SolicitudCrear(PortalSolicitudCrearDTO obj) =>
            await Search<PR_Portal_SolicitudEscrituraResult>("app.PR_Portal_Solicitudes_Crear", new[]
            {
                Entero("@Usuario", obj.Usuario), Entero("@Alu_Id", obj.Alu_Id),
                Texto("@Tipo", obj.Tipo, DbType.AnsiString), Texto("@Asunto", obj.Asunto),
                Texto("@Detalle", obj.Detalle), Fecha("@FechaFalta", obj.FechaFalta)
            });

        public async Task<Answer> SolicitudRetirar(PortalSolicitudRetirarDTO obj) =>
            await Search<PR_Portal_SolicitudEscrituraResult>("app.PR_Portal_Solicitudes_Retirar",
                new[] { Entero("@Usuario", obj.Usuario), Entero("@Sol_Id", obj.Sol_Id) });

        public async Task<Answer> Bandeja(string? estado, string? tipo, string? texto) =>
            await Read<PR_Portal_BandejaResult>("app.PR_Portal_Bandeja_List", new[]
            {
                Texto("@Estado", estado, DbType.AnsiString), Texto("@Tipo", tipo, DbType.AnsiString), Texto("@Texto", texto)
            });

        public async Task<Answer> BandejaResumen() =>
            await Search<PR_Portal_BandejaResumenResult>("app.PR_Portal_Bandeja_Resumen", SinParametros);

        public async Task<Answer> BandejaFind(int solId) =>
            await Search<PR_Portal_BandejaFindResult>("app.PR_Portal_Bandeja_Find", new[] { Entero("@Sol_Id", solId) });

        public async Task<Answer> BandejaHistorial(int solId) =>
            await Read<PR_Portal_BandejaHistorialResult>("app.PR_Portal_Bandeja_Historial", new[] { Entero("@Sol_Id", solId) });

        public async Task<Answer> BandejaCambiar(PortalBandejaCambiarDTO obj) =>
            await Search<PR_Portal_SolicitudEscrituraResult>("app.PR_Portal_Bandeja_Cambiar", new[]
            {
                Entero("@Usuario", obj.Usuario), Entero("@Sol_Id", obj.Sol_Id),
                Texto("@Estado", obj.Estado, DbType.AnsiString), Texto("@Respuesta", obj.Respuesta)
            });

        public async Task<Answer> Invitaciones(string? texto, string? estado, bool soloConHijos) =>
            await Read<PR_Portal_InvitacionesListResult>("app.PR_Portal_Invitaciones_List", new[]
            {
                Texto("@Texto", texto), Texto("@Estado", estado, DbType.AnsiString), Booleano("@SoloConHijos", soloConHijos)
            });

        public async Task<Answer> InvitacionesResumen() =>
            await Search<PR_Portal_InvitacionesResumenResult>("app.PR_Portal_Invitaciones_Resumen", SinParametros);

        public async Task<Answer> InvitacionCrear(int usuario, int encId, string tokenHash, int horas) =>
            await Search<PR_Portal_InvitacionCrearResult>("app.PR_Portal_Invitaciones_Crear", new[]
            {
                Entero("@Usuario", usuario), Entero("@Enc_Id", encId),
                Texto("@TokenHash", tokenHash, DbType.AnsiStringFixedLength), Entero("@Horas", horas)
            });

        public async Task<Answer> InvitacionRevocar(int usuario, int encId) =>
            await Search<PR_Portal_IdResult>("app.PR_Portal_Invitaciones_Revocar", new[] { Entero("@Usuario", usuario), Entero("@Enc_Id", encId) });

        public async Task<Answer> AccesoCambiar(int usuario, int encId, bool suspender) =>
            await Search<PR_Portal_IdResult>("app.PR_Portal_Acceso_Cambiar",
                new[] { Entero("@Usuario", usuario), Entero("@Enc_Id", encId), Booleano("@Suspender", suspender) });

        public async Task<Answer> InvitacionInfo(string tokenHash) =>
            await Search<PR_Portal_InvitacionInfoResult>("app.PR_Portal_Invitaciones_Info",
                new[] { Texto("@TokenHash", tokenHash, DbType.AnsiStringFixedLength) });

        public async Task<Answer> InvitacionAceptar(string tokenHash, string usuName, string contrasenaHash) =>
            await Search<PR_Portal_InvitacionAceptarResult>("app.PR_Portal_Invitaciones_Aceptar", new[]
            {
                Texto("@TokenHash", tokenHash, DbType.AnsiStringFixedLength), Texto("@Usu_Name", usuName),
                Texto("@Contrasena", contrasenaHash, DbType.AnsiString)
            });
    }
}
