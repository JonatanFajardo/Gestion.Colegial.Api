using Gestion.Colegial.DataAccess.Interfaces;
using Gestion.Colegial.Entities;
using Gestion.Colegial.Entities.DTOs;
using Gestion.Colegial.Entities.Entities;
using System.Data;
using System.Data.SqlClient;

namespace Gestion.Colegial.DataAccess.Repositories
{
    /// <summary>
    /// Plan de apoyo al alumno (script 072). Las escrituras devuelven una fila, por eso usan Search.
    /// Si el procedimiento lanza un error, Search lo deja en Answer (Incidents) y no lo relanza.
    /// Todas las lecturas reciben quién lee (verTodos, verConfidenciales, usuId): el procedimiento
    /// decide qué planes puede ver.
    /// </summary>
    public class PlanesApoyoRepository : RepositoryBase, IPlanesApoyoRepository
    {
        private static SqlParameter Entero(string nombre, int? valor) =>
            new SqlParameter() { ParameterName = nombre, DbType = DbType.Int32, Value = (object?)valor ?? DBNull.Value };

        private static SqlParameter Booleano(string nombre, bool valor) =>
            new SqlParameter() { ParameterName = nombre, DbType = DbType.Boolean, Value = valor };

        private static SqlParameter Fecha(string nombre, DateTime? valor) =>
            new SqlParameter() { ParameterName = nombre, DbType = DbType.Date, Value = valor.HasValue ? valor.Value.Date : DBNull.Value };

        private static SqlParameter Texto(string nombre, string? valor, DbType tipo = DbType.String) =>
            new SqlParameter() { ParameterName = nombre, DbType = tipo, Value = string.IsNullOrWhiteSpace(valor) ? DBNull.Value : valor.Trim() };

        /// <summary>Quien lee: si ve todos (gestiona), si ve confidenciales y su usuario.</summary>
        private static SqlParameter[] Lector(bool verTodos, bool verConfidenciales, int? usuId) =>
            new[] { Booleano("@VerTodos", verTodos), Booleano("@VerConfidenciales", verConfidenciales), Entero("@Usu_Id", usuId) };

        private static SqlParameter[] ConLector(SqlParameter primero, bool verTodos, bool verConfidenciales, int? usuId)
        {
            var p = new List<SqlParameter> { primero };
            p.AddRange(Lector(verTodos, verConfidenciales, usuId));
            return p.ToArray();
        }

        /// <summary>Quien escribe: su usuario y sus permisos.</summary>
        private static IEnumerable<SqlParameter> Escritor(PlanApoyoEscritorDTO obj, bool conConfidenciales = true)
        {
            yield return Entero("@Usuario", obj.Usuario);
            yield return Booleano("@PuedeGestionar", obj.PuedeGestionar);
            if (conConfidenciales) yield return Booleano("@VerConfidenciales", obj.VerConfidenciales);
        }

        public async Task<Answer> List(bool verTodos, bool verConfidenciales, int? usuId) =>
            await Read<PR_tbPlanesApoyo_ListResult>("app.PR_tbPlanesApoyo_List", Lector(verTodos, verConfidenciales, usuId));

        public async Task<Answer> Resumen(bool verTodos, bool verConfidenciales, int? usuId) =>
            await Search<PR_tbPlanesApoyo_ResumenResult>("app.PR_tbPlanesApoyo_Resumen", Lector(verTodos, verConfidenciales, usuId));

        /// <summary>Sin fila (Data null) si no existe o la persona no lo puede leer.</summary>
        public async Task<Answer> Find(int id, bool verTodos, bool verConfidenciales, int? usuId) =>
            await Search<PR_tbPlanesApoyo_FindResult>("app.PR_tbPlanesApoyo_Find", ConLector(Entero("@Apo_Id", id), verTodos, verConfidenciales, usuId));

        public async Task<Answer> Pasos(int id, bool verTodos, bool verConfidenciales, int? usuId) =>
            await Read<PR_tbPlanesApoyoAcciones_ListResult>("app.PR_tbPlanesApoyoAcciones_List", ConLector(Entero("@Apo_Id", id), verTodos, verConfidenciales, usuId));

        public async Task<Answer> Notas(int id, bool verTodos, bool verConfidenciales, int? usuId) =>
            await Read<PR_tbPlanesApoyoNotas_ListResult>("app.PR_tbPlanesApoyoNotas_List", ConLector(Entero("@Apo_Id", id), verTodos, verConfidenciales, usuId));

        public async Task<Answer> Estados(int id, bool verTodos, bool verConfidenciales, int? usuId) =>
            await Read<PR_tbPlanesApoyoEstados_ListResult>("app.PR_tbPlanesApoyoEstados_List", ConLector(Entero("@Apo_Id", id), verTodos, verConfidenciales, usuId));

        public async Task<Answer> Usuarios() =>
            await Read<PR_tbPlanesApoyo_UsuariosResult>("app.PR_tbPlanesApoyo_Usuarios", new SqlParameter[] { });

        public async Task<Answer> Alumnos() =>
            await Read<PR_tbPlanesApoyo_AlumnosResult>("app.PR_tbPlanesApoyo_Alumnos", new SqlParameter[] { });

        public async Task<Answer> Secciones(int cunId) =>
            await Read<PR_tbPlanesApoyo_SeccionesResult>("app.PR_tbPlanesApoyo_Secciones", new[] { Entero("@Cun_Id", cunId) });

        public async Task<Answer> AbiertosDeAlumnos(string alumnos, bool verTodos, bool verConfidenciales, int? usuId) =>
            await Read<PR_tbPlanesApoyo_AbiertosDeAlumnosResult>("app.PR_tbPlanesApoyo_AbiertosDeAlumnos",
                ConLector(Texto("@Alumnos", alumnos, DbType.AnsiString), verTodos, verConfidenciales, usuId));

        public async Task<Answer> Crear(PlanApoyoGuardarDTO obj)
        {
            var p = new List<SqlParameter>
            {
                Entero("@Alu_Id", obj.Alu_Id),
                Texto("@Apo_Categoria", obj.Apo_Categoria, DbType.AnsiString),
                Texto("@Apo_Titulo", obj.Apo_Titulo),
                Texto("@Apo_Resumen", obj.Apo_Resumen),
                Fecha("@Apo_FechaInicio", obj.Apo_FechaInicio),
                Fecha("@Apo_FechaRevision", obj.Apo_FechaRevision),
                Entero("@Usu_IdResponsable", obj.Usu_IdResponsable),
                Booleano("@Apo_EsConfidencial", obj.Apo_EsConfidencial),
                Booleano("@Activar", obj.Activar)
            };
            p.AddRange(Escritor(obj, conConfidenciales: false));
            return await Search<PR_tbPlanesApoyo_EscrituraResult>("app.PR_tbPlanesApoyo_Crear", p.ToArray());
        }

        public async Task<Answer> Editar(PlanApoyoGuardarDTO obj)
        {
            var p = new List<SqlParameter>
            {
                Entero("@Apo_Id", obj.Apo_Id),
                Texto("@Apo_Categoria", obj.Apo_Categoria, DbType.AnsiString),
                Texto("@Apo_Titulo", obj.Apo_Titulo),
                Texto("@Apo_Resumen", obj.Apo_Resumen),
                Fecha("@Apo_FechaInicio", obj.Apo_FechaInicio),
                Fecha("@Apo_FechaRevision", obj.Apo_FechaRevision),
                Entero("@Usu_IdResponsable", obj.Usu_IdResponsable),
                Booleano("@Apo_EsConfidencial", obj.Apo_EsConfidencial),
                Entero("@Apo_Version", obj.Apo_Version)
            };
            p.AddRange(Escritor(obj));
            return await Search<PR_tbPlanesApoyo_EscrituraResult>("app.PR_tbPlanesApoyo_Editar", p.ToArray());
        }

        public async Task<Answer> CambiarEstado(PlanApoyoEstadoDTO obj)
        {
            var p = new List<SqlParameter>
            {
                Entero("@Apo_Id", obj.Apo_Id), Texto("@Estado", obj.Estado, DbType.AnsiString), Texto("@Motivo", obj.Motivo)
            };
            p.AddRange(Escritor(obj));
            return await Search<PR_tbPlanesApoyo_EscrituraResult>("app.PR_tbPlanesApoyo_CambiarEstado", p.ToArray());
        }

        public async Task<Answer> AgregarPaso(PlanApoyoPasoDTO obj)
        {
            var p = new List<SqlParameter>
            {
                Entero("@Apo_Id", obj.Apo_Id), Texto("@Apa_Descripcion", obj.Apa_Descripcion),
                Fecha("@Apa_FechaLimite", obj.Apa_FechaLimite), Entero("@Usu_IdResponsable", obj.Usu_IdResponsable)
            };
            p.AddRange(Escritor(obj));
            return await Search<PR_tbPlanesApoyoAcciones_EscrituraResult>("app.PR_tbPlanesApoyoAcciones_Agregar", p.ToArray());
        }

        public async Task<Answer> CompletarPaso(PlanApoyoPasoAccionDTO obj)
        {
            var p = new List<SqlParameter> { Entero("@Apo_Id", obj.Apo_Id), Entero("@Apa_Id", obj.Apa_Id) };
            p.AddRange(Escritor(obj));
            return await Search<PR_tbPlanesApoyoAcciones_EscrituraResult>("app.PR_tbPlanesApoyoAcciones_Completar", p.ToArray());
        }

        public async Task<Answer> QuitarPaso(PlanApoyoPasoAccionDTO obj)
        {
            var p = new List<SqlParameter> { Entero("@Apo_Id", obj.Apo_Id), Entero("@Apa_Id", obj.Apa_Id) };
            p.AddRange(Escritor(obj));
            return await Search<PR_tbPlanesApoyoAcciones_EscrituraResult>("app.PR_tbPlanesApoyoAcciones_Quitar", p.ToArray());
        }

        public async Task<Answer> AgregarNota(PlanApoyoNotaDTO obj)
        {
            var p = new List<SqlParameter> { Entero("@Apo_Id", obj.Apo_Id), Texto("@Apn_Texto", obj.Apn_Texto) };
            p.AddRange(Escritor(obj));
            return await Search<PR_tbPlanesApoyoNotas_AgregarResult>("app.PR_tbPlanesApoyoNotas_Agregar", p.ToArray());
        }

        public async Task<Answer> Eliminar(PlanApoyoEliminarDTO obj)
        {
            var p = new List<SqlParameter> { Entero("@Apo_Id", obj.Apo_Id) };
            p.AddRange(Escritor(obj));
            return await Search<PR_tbPlanesApoyo_EscrituraResult>("app.PR_tbPlanesApoyo_Eliminar", p.ToArray());
        }
    }
}
