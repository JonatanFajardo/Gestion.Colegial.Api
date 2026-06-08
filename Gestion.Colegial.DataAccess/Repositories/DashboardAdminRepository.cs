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
    public class DashboardAdminRepository : RepositoryBase, IDashboardAdminRepository
    {
        public async Task<Answer> Resumen()
        {
            var answer = new Answer();
            try
            {
                var ds = new DataSet();
                using (var con = new SqlConnection(Connection.GetConnectionString()))
                using (var cmd = new SqlCommand("app.PR_DashboardAdmin_Resumen", con))
                {
                    cmd.CommandType = CommandType.StoredProcedure;
                    using var adapter = new SqlDataAdapter(cmd);
                    await Task.Run(() => adapter.Fill(ds));
                }

                DataTable Tbl(int i) => ds.Tables.Count > i ? ds.Tables[i] : new DataTable();

                answer.Data = new DashboardAdminResult
                {
                    Kpis           = Mapear.Convert.ToList<DashboardAdmin_KpisResult>(Tbl(0)).FirstOrDefault(),
                    Bitacora       = Mapear.Convert.ToList<DashboardAdmin_BitacoraResult>(Tbl(1)),
                    UsuariosPorRol = Mapear.Convert.ToList<DashboardAdmin_UsuariosPorRolResult>(Tbl(2)),
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
