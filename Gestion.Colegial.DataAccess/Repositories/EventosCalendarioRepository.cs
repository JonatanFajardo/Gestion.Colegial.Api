using Gestion.Colegial.DataAccess.Interfaces;
using Gestion.Colegial.Entities;
using Gestion.Colegial.Entities.DTOs;
using Gestion.Colegial.Entities.Entities;
using System.Data;
using System.Data.SqlClient;

namespace Gestion.Colegial.DataAccess.Repositories
{
    /// <summary>
    /// Calendario escolar (script 060). Las escrituras devuelven una fila, por eso usan Search.
    /// Si el procedimiento lanza un error, Search lo deja en Answer (Incidents) y no lo relanza.
    /// </summary>
    public class EventosCalendarioRepository : RepositoryBase, IEventosCalendarioRepository
    {
        private static SqlParameter Entero(string nombre, int? valor) =>
            new SqlParameter() { ParameterName = nombre, DbType = DbType.Int32, Value = (object?)valor ?? DBNull.Value };

        private static SqlParameter Fecha(string nombre, DateTime? valor) =>
            new SqlParameter() { ParameterName = nombre, DbType = DbType.Date, Value = valor.HasValue ? valor.Value.Date : DBNull.Value };

        private static SqlParameter FechaHora(string nombre, DateTime valor) =>
            new SqlParameter() { ParameterName = nombre, DbType = DbType.DateTime2, Value = valor };

        private static SqlParameter Booleano(string nombre, bool? valor) =>
            new SqlParameter() { ParameterName = nombre, DbType = DbType.Boolean, Value = (object?)valor ?? DBNull.Value };

        private static SqlParameter Texto(string nombre, string? valor, DbType tipo = DbType.String) =>
            new SqlParameter() { ParameterName = nombre, DbType = tipo, Value = string.IsNullOrWhiteSpace(valor) ? DBNull.Value : valor.Trim() };

        private static string? Lista(List<int>? ids) =>
            ids == null || ids.Count == 0 ? null : string.Join(",", ids.Distinct());

        /// <summary>verTodo = quien edita (todo); si no, lo de todo el colegio + lo que es para la persona (empleado/rol).</summary>
        public async Task<Answer> ListRango(DateTime desde, DateTime hasta, bool incluirBorradores, bool verTodo, int? empId, int? rolId)
        {
            SqlParameter[] p =
            {
                Fecha("@Desde", desde), Fecha("@Hasta", hasta), Booleano("@IncluirBorradores", incluirBorradores),
                Booleano("@VerTodo", verTodo), Entero("@Emp_Id", empId), Entero("@Rol_Id", rolId)
            };
            return await Read<PR_tbEventosCalendario_ListResult>("app.PR_tbEventosCalendario_ListRango", p);
        }

        /// <summary>Sin fila (Data null) si no existe o, con verTodo = false, no está publicado o no es para la persona.</summary>
        public async Task<Answer> Find(int id, bool verTodo, int? empId, int? rolId)
        {
            SqlParameter[] p = { Entero("@Eve_Id", id), Booleano("@VerTodo", verTodo), Entero("@Emp_Id", empId), Entero("@Rol_Id", rolId) };
            return await Search<PR_tbEventosCalendario_ListResult>("app.PR_tbEventosCalendario_Find", p);
        }

        public async Task<Answer> Audiencia(int id)
        {
            SqlParameter[] p = { Entero("@Eve_Id", id) };
            return await Read<PR_tbEventosCalendarioAudiencia_ListResult>("app.PR_tbEventosCalendarioAudiencia_List", p);
        }

        /// <summary>Una fila por mes con borradores (lista vacía si no hay).</summary>
        public async Task<Answer> Borradores()
        {
            SqlParameter[] p = { };
            return await Read<PR_tbEventosCalendario_BorradoresResult>("app.PR_tbEventosCalendario_Borradores", p);
        }

        public async Task<Answer> CierreEnFecha(DateTime fecha, int? seaId, int? horId)
        {
            SqlParameter[] p = { Fecha("@Fecha", fecha), Entero("@Sea_Id", seaId), Entero("@Hor_Id", horId) };
            return await Search<PR_tbEventosCalendario_CierreEnFechaResult>("app.PR_tbEventosCalendario_CierreEnFecha", p);
        }

        public async Task<Answer> Proximos(DateTime? hoy, int dias, bool verTodo, int? empId, int? rolId, int limite)
        {
            SqlParameter[] p =
            {
                Fecha("@Hoy", hoy), Entero("@Dias", dias), Booleano("@VerTodo", verTodo),
                Entero("@Emp_Id", empId), Entero("@Rol_Id", rolId), Entero("@Limite", limite)
            };
            return await Read<PR_tbEventosCalendario_ProximosResult>("app.PR_tbEventosCalendario_Proximos", p);
        }

        public async Task<Answer> ParaAlumno(int aluId, DateTime desde, DateTime hasta)
        {
            SqlParameter[] p = { Entero("@Alu_Id", aluId), Fecha("@Desde", desde), Fecha("@Hasta", hasta) };
            return await Read<PR_tbEventosCalendario_ListResult>("app.PR_tbEventosCalendario_ParaAlumno", p);
        }

        public async Task<Answer> SeccionesAudiencia(DateTime? fecha, int? eveId)
        {
            SqlParameter[] p = { Fecha("@Fecha", fecha), Entero("@Eve_Id", eveId) };
            return await Read<PR_tbEventosCalendario_SeccionesAudienciaResult>("app.PR_tbEventosCalendario_SeccionesAudiencia", p);
        }

        public async Task<Answer> RolesAudiencia()
        {
            SqlParameter[] p = { };
            return await Read<PR_tbEventosCalendario_RolesAudienciaResult>("app.PR_tbEventosCalendario_RolesAudiencia", p);
        }

        public async Task<Answer> BuscarPersonas(string texto, int limite)
        {
            SqlParameter[] p = { Texto("@Texto", texto ?? ""), Entero("@Limite", limite) };
            if (p[0].Value == DBNull.Value) p[0].Value = "";
            return await Read<PR_tbEventosCalendario_BuscarPersonasResult>("app.PR_tbEventosCalendario_BuscarPersonas", p);
        }

        public async Task<Answer> ClavesOrigen(string prefijo)
        {
            SqlParameter[] p = { Texto("@Prefijo", prefijo, DbType.AnsiString) };
            return await Read<PR_tbEventosCalendario_ClavesOrigenResult>("app.PR_tbEventosCalendario_ClavesOrigen", p);
        }

        public async Task<Answer> Guardar(EventoCalendarioGuardarDTO obj)
        {
            SqlParameter[] p =
            {
                Entero("@Eve_Id", obj.Eve_Id),
                Texto("@Eve_Titulo", obj.Eve_Titulo),
                Texto("@Eve_Descripcion", obj.Eve_Descripcion),
                Texto("@Eve_Tipo", obj.Eve_Tipo, DbType.AnsiString),
                Texto("@Eve_Lugar", obj.Eve_Lugar),
                Booleano("@Eve_TodoElDia", obj.Eve_TodoElDia),
                FechaHora("@Eve_Inicio", obj.Eve_Inicio),
                FechaHora("@Eve_Fin", obj.Eve_Fin),
                Texto("@Secciones", Lista(obj.Secciones), DbType.AnsiString),
                Texto("@Roles", Lista(obj.Roles), DbType.AnsiString),
                Texto("@Empleados", Lista(obj.Empleados), DbType.AnsiString),
                Texto("@Alumnos", Lista(obj.Alumnos), DbType.AnsiString),
                Texto("@Eve_ClaveOrigen", obj.Eve_ClaveOrigen, DbType.AnsiString),
                Booleano("@Publicar", obj.Publicar),
                Entero("@Usuario", obj.Usuario)
            };
            return await Search<PR_tbEventosCalendario_GuardarResult>("app.PR_tbEventosCalendario_Guardar", p);
        }

        public async Task<Answer> Publicar(int id, bool publicar, int? usuario)
        {
            SqlParameter[] p = { Entero("@Eve_Id", id), Booleano("@Publicar", publicar), Entero("@Usuario", usuario) };
            return await Search<PR_tbEventosCalendario_PublicarResult>("app.PR_tbEventosCalendario_Publicar", p);
        }

        public async Task<Answer> Eliminar(int id, int? usuario)
        {
            SqlParameter[] p = { Entero("@Eve_Id", id), Entero("@Usuario", usuario) };
            return await Search<PR_tbEventosCalendario_EliminarResult>("app.PR_tbEventosCalendario_Eliminar", p);
        }
    }
}
