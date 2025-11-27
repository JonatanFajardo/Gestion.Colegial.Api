using Gestion.Colegial.DataAccess.Interfaces.Finanzas;
using Gestion.Colegial.Entities;
using Gestion.Colegial.Entities.Entities;
using System.Data;
using System.Data.SqlClient;

namespace Gestion.Colegial.DataAccess.Repositories.Finanzas
{
    public class ReporteFinancieroRepository : RepositoryBase, IReporteFinancieroRepository
    {
        public async Task<Answer> IngresosPorMes(int anio, int mes)
        {
            const string sql = "PR_ReportesFinancieros_IngresosPorMes";
            SqlParameter[] sqlParameters = {
                new SqlParameter(){ParameterName= "@Anio", DbType = DbType.Int32, Value = anio },
                new SqlParameter(){ParameterName= "@Mes", DbType = DbType.Int32, Value = mes },
            };
            Answer answer = await Read<PR_ReportesFinancieros_IngresosPorMesResult>(sql, sqlParameters);
            return answer;
        }

        public async Task<Answer> ProyeccionCobros(int anio, int mes)
        {
            const string sql = "PR_ReportesFinancieros_ProyeccionCobros";
            SqlParameter[] sqlParameters = {
                new SqlParameter(){ParameterName= "@Anio", DbType = DbType.Int32, Value = anio },
                new SqlParameter(){ParameterName= "@Mes", DbType = DbType.Int32, Value = mes },
            };
            Answer answer = await Read<PR_ReportesFinancieros_ProyeccionCobrosResult>(sql, sqlParameters);
            return answer;
        }

        public async Task<Answer> ListadoMorosos()
        {
            const string sql = "PR_ReportesFinancieros_ListadoMorosos";
            Answer answer = await Read<PR_ReportesFinancieros_ListadoMorososResult>(sql);
            return answer;
        }

        public async Task<Answer> EstadoCuentaAlumno(int alumnoId)
        {
            const string sql = "PR_ReportesFinancieros_EstadoCuentaAlumno";
            SqlParameter[] sqlParameters = {
                new SqlParameter(){ParameterName= "@Alu_Id", DbType = DbType.Int32, Value = alumnoId },
            };
            Answer answer = await Read<PR_ReportesFinancieros_EstadoCuentaAlumnoResult>(sql, sqlParameters);
            return answer;
        }

        public async Task<Answer> ComparativaAnual(int anioInicio, int anioFin)
        {
            const string sql = "PR_ReportesFinancieros_ComparativaAnual";
            SqlParameter[] sqlParameters = {
                new SqlParameter(){ParameterName= "@AnioInicio", DbType = DbType.Int32, Value = anioInicio },
                new SqlParameter(){ParameterName= "@AnioFin", DbType = DbType.Int32, Value = anioFin },
            };
            Answer answer = await Read<PR_ReportesFinancieros_ComparativaAnualResult>(sql, sqlParameters);
            return answer;
        }
    }
}
