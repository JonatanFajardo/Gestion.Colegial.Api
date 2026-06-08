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
    public class DashboardSecretariaRepository : RepositoryBase, IDashboardSecretariaRepository
    {
        public async Task<Answer> Resumen(int Anio)
        {
            var answer = new Answer();
            try
            {
                var ds = new DataSet();
                using (var con = new SqlConnection(Connection.GetConnectionString()))
                using (var cmd = new SqlCommand("app.PR_DashboardSecretaria_Resumen", con))
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

                answer.Data = new DashboardSecretariaResult
                {
                    Kpis                     = Mapear.Convert.ToList<DashboardSecretaria_KpisResult>(Tbl(0)).FirstOrDefault(),
                    MatriculaPorSeccion      = Mapear.Convert.ToList<DashboardSecretaria_MatriculaPorSeccionResult>(Tbl(1)),
                    TramitesHoy              = Mapear.Convert.ToList<DashboardSecretaria_TramiteResult>(Tbl(2)),
                    MatriculaPorMes          = Mapear.Convert.ToList<DashboardSecretaria_MatriculaPorMesResult>(Tbl(3)),
                    DocumentosPorTipo        = Mapear.Convert.ToList<DashboardSecretaria_DocumentoPorTipoResult>(Tbl(4)),
                    AlumnosConDocsPendientes = Mapear.Convert.ToList<DashboardSecretaria_AlumnoDocsPendientesResult>(Tbl(5)),
                    EncargadosIncompletos    = Mapear.Convert.ToList<DashboardSecretaria_EncargadoIncompletoResult>(Tbl(6)),
                    CumpleanosSemana         = Mapear.Convert.ToList<DashboardSecretaria_CumpleanosResult>(Tbl(7)),
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
