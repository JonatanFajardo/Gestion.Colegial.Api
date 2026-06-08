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
    public class DashboardRRHHRepository : RepositoryBase, IDashboardRRHHRepository
    {
        public async Task<Answer> Resumen(int Anio, int Mes)
        {
            var answer = new Answer();
            try
            {
                var ds = new DataSet();
                using (var con = new SqlConnection(Connection.GetConnectionString()))
                using (var cmd = new SqlCommand("app.PR_DashboardRRHH_Resumen", con))
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

                answer.Data = new DashboardRRHHResult
                {
                    Kpis                  = Mapear.Convert.ToList<DashboardRRHH_KpisResult>(Tbl(0)).FirstOrDefault(),
                    PorDepartamento       = Mapear.Convert.ToList<DashboardRRHH_PorDepartamentoResult>(Tbl(1)),
                    PorCargo              = Mapear.Convert.ToList<DashboardRRHH_PorCargoResult>(Tbl(2)),
                    AsistenciaDiaria      = Mapear.Convert.ToList<DashboardRRHH_AsistenciaDiariaResult>(Tbl(3)),
                    SolicitudesPorTipo    = Mapear.Convert.ToList<DashboardRRHH_SolicitudTipoResult>(Tbl(4)),
                    NuevosPorMes          = Mapear.Convert.ToList<DashboardRRHH_NuevosPorMesResult>(Tbl(5)),
                    PorGenero             = Mapear.Convert.ToList<DashboardRRHH_PorGeneroResult>(Tbl(6)),
                    PorEdad               = Mapear.Convert.ToList<DashboardRRHH_PorEdadResult>(Tbl(7)),
                    Cumpleanos            = Mapear.Convert.ToList<DashboardRRHH_CumpleanosResult>(Tbl(8)),
                    SolicitudesPendientes = Mapear.Convert.ToList<DashboardRRHH_SolicitudDetalleResult>(Tbl(9)),
                    TopAntiguedad         = Mapear.Convert.ToList<DashboardRRHH_AntiguedadResult>(Tbl(10)),
                    Alertas               = Mapear.Convert.ToList<DashboardRRHH_AlertaResult>(Tbl(11)),
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
