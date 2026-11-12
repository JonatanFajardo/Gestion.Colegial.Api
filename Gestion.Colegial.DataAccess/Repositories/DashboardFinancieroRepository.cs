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
    public class DashboardFinancieroRepository : RepositoryBase, IDashboardFinancieroRepository
    {
        public async Task<Answer> Resumen(int Anio, int Mes)
        {
            var answer = new Answer();
            try
            {
                var ds = new DataSet();
                using (var con = new SqlConnection(Connection.GetConnectionString()))
                using (var cmd = new SqlCommand("app.PR_DashboardFinanciero_Resumen", con))
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

                answer.Data = new DashboardFinancieroResult
                {
                    KpisFinancieros      = Mapear.Convert.ToList<DashboardFinanciero_KpisFinancierosResult>(Tbl(0)).FirstOrDefault(),
                    IngresosMensuales    = Mapear.Convert.ToList<DashboardFinanciero_IngresosMensualesResult>(Tbl(1)),
                    CobrosPorFormaPago   = Mapear.Convert.ToList<DashboardFinanciero_CobrosPorFormaPagoResult>(Tbl(2)),
                    MorosidadPorConcepto = Mapear.Convert.ToList<DashboardFinanciero_MorosidadPorConceptoResult>(Tbl(3)),
                    TopAlumnosMorosos    = Mapear.Convert.ToList<DashboardFinanciero_TopAlumnoMorosoResult>(Tbl(4)),
                    CobrosPorDia         = Mapear.Convert.ToList<DashboardFinanciero_CobrosPorDiaResult>(Tbl(5)),
                    EstadoCartera        = Mapear.Convert.ToList<DashboardFinanciero_EstadoCarteraResult>(Tbl(6)),
                    CuentasPorVencer     = Mapear.Convert.ToList<DashboardFinanciero_CuentaPorVencerResult>(Tbl(7)),
                    CobrosPorConcepto    = Mapear.Convert.ToList<DashboardFinanciero_CobrosPorConceptoResult>(Tbl(8)),
                    Alertas              = Mapear.Convert.ToList<DashboardFinanciero_AlertaResult>(Tbl(9)),
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
