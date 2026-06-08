using Gestion.Colegial.DataAccess.Interfaces;
using Gestion.Colegial.Entities;
using Gestion.Colegial.Entities.Entities;
using System.Data;
using System.Data.SqlClient;
using System.Threading.Tasks;

namespace Gestion.Colegial.DataAccess.Repositories
{
    public class EmpleadosCumpleanosRepository : RepositoryBase, IEmpleadosCumpleanosRepository
    {
        public async Task<Answer> List(int? Mes)
        {
            const string sql = "app.PR_Empleados_Cumpleanos";
            SqlParameter[] parameters =
            {
                new SqlParameter { ParameterName = "@Mes", DbType = DbType.Int32, Value = (object)Mes ?? System.DBNull.Value },
            };
            return await SearchAll<PR_Empleados_CumpleanosResult>(sql, parameters);
        }
    }
}
