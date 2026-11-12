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
    public class DashboardCajeroRepository : RepositoryBase, IDashboardCajeroRepository
    {
        public async Task<Answer> Resumen(int Usu_Id, DateTime? Fecha)
        {
            var answer = new Answer();
            try
            {
                var ds = new DataSet();
                using (var con = new SqlConnection(Connection.GetConnectionString()))
                using (var cmd = new SqlCommand("app.PR_DashboardCajero_Hoy", con))
                {
                    cmd.CommandType = CommandType.StoredProcedure;
                    cmd.Parameters.AddRange(new[]
                    {
                        new SqlParameter { ParameterName = "@Usu_Id", DbType = DbType.Int32, Value = Usu_Id },
                        new SqlParameter { ParameterName = "@Fecha",  DbType = DbType.Date,  Value = (object?)Fecha ?? DBNull.Value },
                    });
                    using var adapter = new SqlDataAdapter(cmd);
                    await Task.Run(() => adapter.Fill(ds));
                }

                DataTable Tbl(int i) => ds.Tables.Count > i ? ds.Tables[i] : new DataTable();

                answer.Data = new DashboardCajeroResult
                {
                    Kpis               = Mapear.Convert.ToList<DashboardCajero_KpisCajaResult>(Tbl(0)).FirstOrDefault(),
                    PagosPorHora       = Mapear.Convert.ToList<DashboardCajero_PagosPorHoraResult>(Tbl(1)),
                    CobrosPorFormaPago = Mapear.Convert.ToList<DashboardCajero_CobrosPorFormaPagoResult>(Tbl(2)),
                    CobrosPorConcepto  = Mapear.Convert.ToList<DashboardCajero_CobrosPorConceptoResult>(Tbl(3)),
                    TimelinePagos      = Mapear.Convert.ToList<DashboardCajero_TimelinePagosResult>(Tbl(4)),
                    TopAlumnosDelDia   = Mapear.Convert.ToList<DashboardCajero_TopAlumnoDelDiaResult>(Tbl(5)),
                    CuentasVencidas    = Mapear.Convert.ToList<DashboardCajero_CuentaVencidaResult>(Tbl(6)),
                    UltimoArqueo       = Mapear.Convert.ToList<DashboardCajero_UltimoArqueoResult>(Tbl(7)).FirstOrDefault(),
                    ResumenSemanal     = Mapear.Convert.ToList<DashboardCajero_ResumenSemanalResult>(Tbl(8)),
                    Alertas            = Mapear.Convert.ToList<DashboardCajero_AlertaResult>(Tbl(9)),
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
