using Gestion.Colegial.DataAccess.Interfaces;
using Gestion.Colegial.Entities;
using Gestion.Colegial.Entities.Entities;
using System.Data;
using System.Data.SqlClient;

namespace Gestion.Colegial.DataAccess.Repositories
{
    public class AnalisisIngresosRepository : RepositoryBase, IAnalisisIngresosRepository
    {
        public async Task<Answer> List(int Anio)
        {
            const string sql = "finanza.PR_Finanza_AnalisisIngresos";
            SqlParameter[] parameters =
            {
                new SqlParameter { ParameterName = "@Anio", DbType = DbType.Int32, Value = Anio },
            };
            return await SearchAll<PR_Finanza_AnalisisIngresosResult>(sql, parameters);
        }
    }
}
