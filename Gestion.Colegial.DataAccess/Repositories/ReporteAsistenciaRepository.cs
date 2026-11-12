using Gestion.Colegial.DataAccess.Interfaces;
using Gestion.Colegial.Entities;
using Gestion.Colegial.Entities.Entities;
using System.Data;
using System.Data.SqlClient;

namespace Gestion.Colegial.DataAccess.Repositories
{
    /// <summary>
    /// Reporte de asistencia de alumnos (script 063). Los procedimientos de una sola fila
    /// (Anio, SeccionInfo) usan Search; el resto, Read.
    /// </summary>
    public class ReporteAsistenciaRepository : RepositoryBase, IReporteAsistenciaRepository
    {
        private static SqlParameter Entero(string nombre, int? valor) =>
            new SqlParameter() { ParameterName = nombre, SqlDbType = SqlDbType.Int, Value = (object?)valor ?? DBNull.Value };

        private static SqlParameter Fecha(string nombre, DateTime valor) =>
            new SqlParameter() { ParameterName = nombre, SqlDbType = SqlDbType.Date, Value = valor.Date };

        /// <summary>Sección y rango de fechas, comunes a Alumnos, Dias y Planilla.</summary>
        private static SqlParameter[] SeccionRango(int seaId, DateTime desde, DateTime hasta) =>
            new[] { Entero("@Sea_Id", seaId), Fecha("@Desde", desde), Fecha("@Hasta", hasta) };

        public async Task<Answer> Anio(DateTime fecha) =>
            await Search<PR_ReporteAsistencia_AnioResult>("app.PR_ReporteAsistencia_Anio", new[] { Fecha("@Fecha", fecha) });

        public async Task<Answer> Periodos(int aniId) =>
            await Read<PR_ReporteAsistencia_PeriodosResult>("app.PR_ReporteAsistencia_Periodos", new[] { Entero("@Ani_Id", aniId) });

        public async Task<Answer> Filtros(int aniId, int? empId) =>
            await Read<PR_ReporteAsistencia_FiltrosResult>("app.PR_ReporteAsistencia_Filtros",
                new[] { Entero("@Ani_Id", aniId), Entero("@Emp_Id", empId) });

        public async Task<Answer> Secciones(int aniId, DateTime desde, DateTime hasta, int? nivId, int? cunId, int? seaId, int? empId)
        {
            SqlParameter[] p =
            {
                Entero("@Ani_Id", aniId), Fecha("@Desde", desde), Fecha("@Hasta", hasta),
                Entero("@Niv_Id", nivId), Entero("@Cun_Id", cunId), Entero("@Sea_Id", seaId), Entero("@Emp_Id", empId)
            };
            return await Read<PR_ReporteAsistencia_SeccionesResult>("app.PR_ReporteAsistencia_Secciones", p);
        }

        public async Task<Answer> SeccionInfo(int seaId) =>
            await Search<PR_ReporteAsistencia_SeccionInfoResult>("app.PR_ReporteAsistencia_SeccionInfo", new[] { Entero("@Sea_Id", seaId) });

        public async Task<Answer> Alumnos(int seaId, DateTime desde, DateTime hasta) =>
            await Read<PR_ReporteAsistencia_AlumnosResult>("app.PR_ReporteAsistencia_Alumnos", SeccionRango(seaId, desde, hasta));

        public async Task<Answer> Dias(int seaId, DateTime desde, DateTime hasta) =>
            await Read<PR_ReporteAsistencia_DiasResult>("app.PR_ReporteAsistencia_Dias", SeccionRango(seaId, desde, hasta));

        public async Task<Answer> Planilla(int seaId, DateTime desde, DateTime hasta) =>
            await Read<PR_ReporteAsistencia_PlanillaResult>("app.PR_ReporteAsistencia_Planilla", SeccionRango(seaId, desde, hasta));
    }
}
