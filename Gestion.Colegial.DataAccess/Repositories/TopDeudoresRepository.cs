using System;
using Gestion.Colegial.DataAccess.Interfaces;
using Gestion.Colegial.Entities;
using Gestion.Colegial.Entities.Entities;
using System.Data;
using System.Data.SqlClient;
using System.Threading.Tasks;

namespace Gestion.Colegial.DataAccess.Repositories
{
    public class TopDeudoresRepository : RepositoryBase, ITopDeudoresRepository
    {
        public async Task<Answer> List(int? Top, int? Anio)
        {
            const string sql = "finanza.PR_Finanza_TopDeudores";
            SqlParameter[] parameters =
            {
                new SqlParameter { ParameterName = "@Top", DbType = DbType.Int32, Value = (object)Top ?? DBNull.Value },
                new SqlParameter { ParameterName = "@Anio", DbType = DbType.Int32, Value = (object)Anio ?? DBNull.Value },
            };
            return await SearchAll<TopDeudoresResult>(sql, parameters);
        }
    }
}
