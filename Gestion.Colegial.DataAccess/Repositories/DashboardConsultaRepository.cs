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
    public class DashboardConsultaRepository : RepositoryBase, IDashboardConsultaRepository
    {
        public async Task<Answer> Resumen(int Anio)
        {
            var answer = new Answer();
            try
            {
                var ds = new DataSet();
                using (var con = new SqlConnection(Connection.GetConnectionString()))
                using (var cmd = new SqlCommand("app.PR_DashboardConsulta_KPIs", con))
                {
                    cmd.CommandType = CommandType.StoredProcedure;
                    cmd.Parameters.AddRange(new[]
                    {
                        new SqlParameter { ParameterName = "@Anio", DbType = DbType.Int32, Value = Anio },
                    });
                    using var adapter = new SqlDataAdapter(cmd);
                    await Task.Run(() => adapter.Fill(ds));
                }

                DataTable Tbl(int i) => ds.Tables.Count > i ? ds.Tables[i] : new DataTable();

                answer.Data = new DashboardConsultaResult
                {
                    Kpis                       = Mapear.Convert.ToList<DashboardConsulta_KpisResult>(Tbl(0)).FirstOrDefault(),
                    EvolucionMatricula         = Mapear.Convert.ToList<DashboardConsulta_EvolucionMatriculaResult>(Tbl(1)),
                    MatriculaPorNivel          = Mapear.Convert.ToList<DashboardConsulta_MatriculaPorNivelResult>(Tbl(2)),
                    MatriculaPorJornada        = Mapear.Convert.ToList<DashboardConsulta_MatriculaPorJornadaResult>(Tbl(3)),
                    MatriculaPorCurso          = Mapear.Convert.ToList<DashboardConsulta_MatriculaPorCursoResult>(Tbl(4)),
                    AlumnosPorGenero           = Mapear.Convert.ToList<DashboardConsulta_AlumnosPorGeneroResult>(Tbl(5)),
                    AlumnosPorEdad             = Mapear.Convert.ToList<DashboardConsulta_AlumnosPorEdadResult>(Tbl(6)),
                    EmpleadosPorDepartamento   = Mapear.Convert.ToList<DashboardConsulta_EmpleadosPorDepartamentoResult>(Tbl(7)),
                    EmpleadosPorCargo          = Mapear.Convert.ToList<DashboardConsulta_EmpleadosPorCargoResult>(Tbl(8)),
                    IndicadoresInstitucionales = Mapear.Convert.ToList<DashboardConsulta_IndicadorInstitucionalResult>(Tbl(9)),
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
