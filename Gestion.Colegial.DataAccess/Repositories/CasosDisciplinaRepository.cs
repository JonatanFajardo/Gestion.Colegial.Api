using Gestion.Colegial.DataAccess.Interfaces;
using Gestion.Colegial.Entities;
using Gestion.Colegial.Entities.DTOs;
using Gestion.Colegial.Entities.Entities;
using System.Data;
using System.Data.SqlClient;
using System.Text.Json;

namespace Gestion.Colegial.DataAccess.Repositories
{
    /// <summary>
    /// Disciplina (script 062). Las escrituras devuelven una fila, por eso usan Search.
    /// Si el procedimiento lanza un error, Search lo deja en Answer (Incidents) y no lo relanza.
    /// </summary>
    public class CasosDisciplinaRepository : RepositoryBase, ICasosDisciplinaRepository
    {
        private static SqlParameter Entero(string nombre, int? valor) =>
            new SqlParameter() { ParameterName = nombre, DbType = DbType.Int32, Value = (object?)valor ?? DBNull.Value };

        private static SqlParameter Booleano(string nombre, bool valor) =>
            new SqlParameter() { ParameterName = nombre, DbType = DbType.Boolean, Value = valor };

        private static SqlParameter Fecha(string nombre, DateTime? valor) =>
            new SqlParameter() { ParameterName = nombre, DbType = DbType.Date, Value = valor.HasValue ? valor.Value.Date : DBNull.Value };

        private static SqlParameter FechaHora(string nombre, DateTime valor) =>
            new SqlParameter() { ParameterName = nombre, DbType = DbType.DateTime2, Value = valor };

        private static SqlParameter Texto(string nombre, string? valor, DbType tipo = DbType.String) =>
            new SqlParameter() { ParameterName = nombre, DbType = tipo, Value = string.IsNullOrWhiteSpace(valor) ? DBNull.Value : valor.Trim() };

        /// <summary>Quien lee: permiso de reservados, su usuario y su empleado.</summary>
        private static SqlParameter[] Lector(bool verReservados, int? usuId, int? empId) =>
            new[] { Booleano("@VerReservados", verReservados), Entero("@Usu_Id", usuId), Entero("@Emp_Id", empId) };

        public async Task<Answer> List(string? estado, string? tipo, bool soloAbiertos, bool verReservados, int? usuId, int? empId, int pagina, int tamano)
        {
            var p = new List<SqlParameter>
            {
                Texto("@Estado", estado, DbType.AnsiString), Texto("@Tipo", tipo, DbType.AnsiString), Booleano("@SoloAbiertos", soloAbiertos),
                Entero("@Pagina", pagina), Entero("@Tamano", tamano)
            };
            p.AddRange(Lector(verReservados, usuId, empId));
            return await Read<PR_tbCasosDisciplina_ListResult>("app.PR_tbCasosDisciplina_List", p.ToArray());
        }

        public async Task<Answer> Abiertos(bool verReservados, int? usuId, int? empId) =>
            await Search<PR_tbCasosDisciplina_AbiertosResult>("app.PR_tbCasosDisciplina_Abiertos", Lector(verReservados, usuId, empId));

        /// <summary>Sin fila (Data null) si no existe o la persona no lo puede leer.</summary>
        public async Task<Answer> Find(int id, bool verReservados, int? usuId, int? empId)
        {
            var p = new List<SqlParameter> { Entero("@Cas_Id", id) };
            p.AddRange(Lector(verReservados, usuId, empId));
            return await Search<PR_tbCasosDisciplina_FindResult>("app.PR_tbCasosDisciplina_Find", p.ToArray());
        }

        public async Task<Answer> Personas(int id) =>
            await Read<PR_tbCasosDisciplinaPersonas_ListResult>("app.PR_tbCasosDisciplinaPersonas_List", new[] { Entero("@Cas_Id", id) });

        public async Task<Answer> Acciones(int id) =>
            await Read<PR_tbCasosDisciplinaAcciones_ListResult>("app.PR_tbCasosDisciplinaAcciones_List", new[] { Entero("@Cas_Id", id) });

        public async Task<Answer> Estados(int id) =>
            await Read<PR_tbCasosDisciplinaEstados_ListResult>("app.PR_tbCasosDisciplinaEstados_List", new[] { Entero("@Cas_Id", id) });

        public async Task<Answer> Notas(int id, bool verReservados, int? usuId, int? empId)
        {
            var p = new List<SqlParameter> { Entero("@Cas_Id", id) };
            p.AddRange(Lector(verReservados, usuId, empId));
            return await Read<PR_tbCasosDisciplinaNotas_ListResult>("app.PR_tbCasosDisciplinaNotas_List", p.ToArray());
        }

        public async Task<Answer> Alumnos() =>
            await Read<PR_tbCasosDisciplina_AlumnosResult>("app.PR_tbCasosDisciplina_Alumnos", new SqlParameter[] { });

        public async Task<Answer> Empleados() =>
            await Read<PR_tbCasosDisciplina_EmpleadosResult>("app.PR_tbCasosDisciplina_Empleados", new SqlParameter[] { });

        public async Task<Answer> Registrar(CasoDisciplinaRegistrarDTO obj)
        {
            string? personas = obj.Personas == null || obj.Personas.Count == 0
                ? null
                : JsonSerializer.Serialize(obj.Personas.Where(x => x.Alu_Id.HasValue).ToList());

            SqlParameter[] p =
            {
                Texto("@Cas_Resumen", obj.Cas_Resumen),
                Texto("@Cas_Tipo", obj.Cas_Tipo, DbType.AnsiString),
                Texto("@Cas_Descripcion", obj.Cas_Descripcion),
                Texto("@Cas_Lugar", obj.Cas_Lugar),
                FechaHora("@Cas_FechaOcurrio", obj.Cas_FechaOcurrio),
                Entero("@Emp_IdAtiende", obj.Emp_IdAtiende),
                Texto("@Personas", personas),
                Entero("@Usuario", obj.Usuario)
            };
            return await Search<PR_tbCasosDisciplina_RegistrarResult>("app.PR_tbCasosDisciplina_Registrar", p);
        }

        public async Task<Answer> CambiarEstado(CasoDisciplinaEstadoDTO obj)
        {
            SqlParameter[] p =
            {
                Entero("@Cas_Id", obj.Cas_Id), Texto("@Estado", obj.Estado, DbType.AnsiString),
                Texto("@Motivo", obj.Motivo), Entero("@Usuario", obj.Usuario)
            };
            return await Search<PR_tbCasosDisciplina_CambiarEstadoResult>("app.PR_tbCasosDisciplina_CambiarEstado", p);
        }

        public async Task<Answer> AgregarAccion(CasoDisciplinaAccionDTO obj)
        {
            SqlParameter[] p =
            {
                Entero("@Cas_Id", obj.Cas_Id), Texto("@Cac_Tipo", obj.Cac_Tipo), Texto("@Cac_Descripcion", obj.Cac_Descripcion),
                Fecha("@Cac_FechaLimite", obj.Cac_FechaLimite), Entero("@Emp_IdResponsable", obj.Emp_IdResponsable),
                Entero("@Usuario", obj.Usuario)
            };
            return await Search<PR_tbCasosDisciplinaAcciones_AgregarResult>("app.PR_tbCasosDisciplinaAcciones_Agregar", p);
        }

        public async Task<Answer> CompletarAccion(int casId, int cacId, int? usuario)
        {
            SqlParameter[] p = { Entero("@Cas_Id", casId), Entero("@Cac_Id", cacId), Entero("@Usuario", usuario) };
            return await Search<PR_tbCasosDisciplinaAcciones_AgregarResult>("app.PR_tbCasosDisciplinaAcciones_Completar", p);
        }

        public async Task<Answer> AgregarNota(CasoDisciplinaNotaDTO obj)
        {
            SqlParameter[] p =
            {
                Entero("@Cas_Id", obj.Cas_Id), Texto("@Cno_Texto", obj.Cno_Texto),
                Booleano("@Cno_EsPrivada", obj.Cno_EsPrivada), Entero("@Usuario", obj.Usuario)
            };
            return await Search<PR_tbCasosDisciplinaNotas_AgregarResult>("app.PR_tbCasosDisciplinaNotas_Agregar", p);
        }
    }
}
