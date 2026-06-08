using Gestion.Colegial.DataAccess.Interfaces;
using Gestion.Colegial.Entities;
using Gestion.Colegial.Entities.Entities;
using System.Data;
using System.Data.SqlClient;

namespace Gestion.Colegial.DataAccess.Repositories
{
    public class FlujoCajaRepository : RepositoryBase, IFlujoCajaRepository
    {
        public async Task<Answer> List(int Anio)
        {
            const string sql = "finanza.PR_Finanza_FlujoCaja";
            SqlParameter[] parameters =
            {
                new SqlParameter { ParameterName = "@Anio", DbType = DbType.Int32, Value = Anio },
            };
            return await SearchAll<PR_Finanza_FlujoCajaResult>(sql, parameters);
        }
    }
}
