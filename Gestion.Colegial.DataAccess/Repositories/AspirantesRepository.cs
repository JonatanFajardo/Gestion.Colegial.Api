using Gestion.Colegial.DataAccess.Interfaces;
using Gestion.Colegial.Entities;
using Gestion.Colegial.Entities.DTOs;
using Gestion.Colegial.Entities.Entities;
using System.Data;
using System.Data.SqlClient;

namespace Gestion.Colegial.DataAccess.Repositories
{
    /// <summary>
    /// Lista de espera de admisión (script 071). Las escrituras devuelven una fila, por eso usan Search.
    /// Si el procedimiento lanza un error, Search lo deja en Answer (Incidents) y no lo relanza.
    /// </summary>
    public class AspirantesRepository : RepositoryBase, IAspirantesRepository
    {
        private static SqlParameter Entero(string nombre, int? valor) =>
            new SqlParameter() { ParameterName = nombre, DbType = DbType.Int32, Value = (object?)valor ?? DBNull.Value };

        private static SqlParameter Fecha(string nombre, DateTime? valor) =>
            new SqlParameter() { ParameterName = nombre, DbType = DbType.Date, Value = valor.HasValue ? valor.Value.Date : DBNull.Value };

        private static SqlParameter Texto(string nombre, string? valor, DbType tipo = DbType.String) =>
            new SqlParameter() { ParameterName = nombre, DbType = tipo, Value = string.IsNullOrWhiteSpace(valor) ? DBNull.Value : valor.Trim() };

        public async Task<Answer> Anios() =>
            await Read<PR_tbAspirantes_AniosResult>("app.PR_tbAspirantes_Anios", new SqlParameter[] { });

        public async Task<Answer> Resumen(int aniId) =>
            await Read<PR_tbAspirantes_ResumenResult>("app.PR_tbAspirantes_Resumen", new[] { Entero("@Ani_Id", aniId) });

        public async Task<Answer> List(int aniId) =>
            await Read<PR_tbAspirantes_ListResult>("app.PR_tbAspirantes_List", new[] { Entero("@Ani_Id", aniId) });

        /// <summary>Sin fila (Data null) si no existe.</summary>
        public async Task<Answer> Find(int id) =>
            await Search<PR_tbAspirantes_FindResult>("app.PR_tbAspirantes_Find", new[] { Entero("@Asp_Id", id) });

        public async Task<Answer> Historial(int id) =>
            await Read<PR_tbAspirantesHistorial_ListResult>("app.PR_tbAspirantesHistorial_List", new[] { Entero("@Asp_Id", id) });

        public async Task<Answer> Cursos(int cunId) =>
            await Read<PR_tbAspirantes_CursosResult>("app.PR_tbAspirantes_Cursos", new[] { Entero("@Cun_Id", cunId) });

        public async Task<Answer> Duplicado(int aniId, string? identidad, string? nombres, string? apellidos, DateTime? fechaNacimiento, int? aspId)
        {
            SqlParameter[] p =
            {
                Entero("@Ani_Id", aniId),
                Texto("@Asp_Identidad", identidad, DbType.AnsiString),
                Texto("@Asp_Nombres", nombres),
                Texto("@Asp_Apellidos", apellidos),
                Fecha("@Asp_FechaNacimiento", fechaNacimiento),
                Entero("@Asp_Id", aspId)
            };
            return await Search<PR_tbAspirantes_DuplicadoResult>("app.PR_tbAspirantes_Duplicado", p);
        }

        public async Task<Answer> Guardar(AspiranteGuardarDTO obj)
        {
            SqlParameter[] p =
            {
                Entero("@Asp_Id", obj.Asp_Id > 0 ? obj.Asp_Id : null),
                Entero("@Ani_Id", obj.Ani_Id),
                Texto("@Asp_Nombres", obj.Asp_Nombres),
                Texto("@Asp_Apellidos", obj.Asp_Apellidos),
                Texto("@Asp_Identidad", obj.Asp_Identidad, DbType.AnsiString),
                Fecha("@Asp_FechaNacimiento", obj.Asp_FechaNacimiento),
                Texto("@Asp_Sexo", obj.Asp_Sexo, DbType.AnsiString),
                Texto("@Asp_EscuelaProcedencia", obj.Asp_EscuelaProcedencia),
                Texto("@Asp_EncargadoNombre", obj.Asp_EncargadoNombre),
                Texto("@Asp_EncargadoIdentidad", obj.Asp_EncargadoIdentidad, DbType.AnsiString),
                Entero("@Par_Id", obj.Par_Id),
                Texto("@Asp_EncargadoTelefono", obj.Asp_EncargadoTelefono, DbType.AnsiString),
                Texto("@Asp_EncargadoCorreo", obj.Asp_EncargadoCorreo),
                Entero("@Niv_Id", obj.Niv_Id),
                Entero("@Cun_Id", obj.Cun_Id),
                Entero("@Mda_Id", obj.Mda_Id),
                Entero("@Cur_Id", obj.Cur_Id),
                Fecha("@Asp_FechaSolicitud", obj.Asp_FechaSolicitud),
                Entero("@Asp_Prioridad", obj.Asp_Prioridad),
                Texto("@Asp_MotivoPrioridad", obj.Asp_MotivoPrioridad),
                Texto("@Asp_Notas", obj.Asp_Notas),
                Entero("@Usuario", obj.Usuario)
            };
            return await Search<PR_tbAspirantes_GuardarResult>("app.PR_tbAspirantes_Guardar", p);
        }

        public async Task<Answer> CambiarEstado(int aspId, string accion, string? motivo, int? aluId, int? usuario)
        {
            SqlParameter[] p =
            {
                Entero("@Asp_Id", aspId),
                Texto("@Accion", accion, DbType.AnsiString),
                Texto("@Motivo", motivo),
                Entero("@Alu_Id", aluId),
                Entero("@Usuario", usuario)
            };
            return await Search<PR_tbAspirantes_CambiarEstadoResult>("app.PR_tbAspirantes_CambiarEstado", p);
        }
    }
}
