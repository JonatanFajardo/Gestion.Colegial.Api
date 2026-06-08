using System;
using Gestion.Colegial.DataAccess.Interfaces;
using Gestion.Colegial.Entities;
using Gestion.Colegial.Entities.Entities;
using System.Data;
using System.Data.SqlClient;
using System.Threading.Tasks;

namespace Gestion.Colegial.DataAccess.Repositories
{
    public class AgingCuentasRepository : RepositoryBase, IAgingCuentasRepository
    {
        public async Task<Answer> List(DateTime? FechaCorte)
        {
            const string sql = "finanza.PR_Finanza_AgingCuentas";
            SqlParameter[] parameters =
            {
                new SqlParameter { ParameterName = "@FechaCorte", DbType = DbType.Date, Value = (object)FechaCorte ?? DBNull.Value },
            };
            return await SearchAll<AgingCuentasResult>(sql, parameters);
        }
    }
}
