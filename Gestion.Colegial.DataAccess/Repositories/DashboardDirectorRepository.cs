using System;
using Gestion.Colegial.DataAccess.Extensions;
using Gestion.Colegial.DataAccess.Interfaces;
using Gestion.Colegial.Entities;
using Gestion.Colegial.Entities.Entities;
using System.Data;
using System.Data.SqlClient;
using System.Linq;
using System.Threading.Tasks;

namespace Gestion.Colegial.DataAccess.Repositories
{
    public class DashboardDirectorRepository : RepositoryBase, IDashboardDirectorRepository
    {
        public async Task<Answer> Resumen(int Anio, int Mes)
        {
            var answer = new Answer();
            try
            {
                var ds = new DataSet();
                using (var con = new SqlConnection(Connection.GetConnectionString()))
                using (var cmd = new SqlCommand("app.PR_DashboardDirector_KPIs", con))
                {
                    cmd.CommandType = CommandType.StoredProcedure;
                    cmd.Parameters.AddRange(new[]
                    {
                        new SqlParameter { ParameterName = "@Anio", DbType = DbType.Int32, Value = Anio },
                        new SqlParameter { ParameterName = "@Mes",  DbType = DbType.Int32, Value = Mes  },
                    });
                    using var adapter = new SqlDataAdapter(cmd);
                    await Task.Run(() => adapter.Fill(ds));
                }

                DataTable Tbl(int i) => ds.Tables.Count > i ? ds.Tables[i] : new DataTable();

                answer.Data = new DashboardDirectorResult
                {
                    Kpis                = Mapear.Convert.ToList<DashboardDirector_KpisResult>(Tbl(0)).FirstOrDefault(),
                    MatriculaPorCurso   = Mapear.Convert.ToList<DashboardDirector_MatriculaPorCursoResult>(Tbl(1)),
                    CobrosPorMes        = Mapear.Convert.ToList<DashboardDirector_CobrosPorMesResult>(Tbl(2)),
                    AsistenciaHoy       = Mapear.Convert.ToList<DashboardDirector_AsistenciaHoyCursoResult>(Tbl(3)),
                    RendimientoPorCurso = Mapear.Convert.ToList<DashboardDirector_RendimientoCursoResult>(Tbl(4)),
                    TopDeuda            = Mapear.Convert.ToList<DashboardDirector_TopDeudaResult>(Tbl(5)),
                    Alertas             = Mapear.Convert.ToList<DashboardDirector_AlertaResult>(Tbl(6)),
                };
                answer.Access = false;
            }
            catch (Exception e)
            {
                answer.Access = true;
                answer.Incidents(e);
            }
            return answer;
        }
    }
}
