using Gestion.Colegial.DataAccess.Interfaces;
using Gestion.Colegial.Entities;
using Gestion.Colegial.Entities.Entities;
using System.Data;
using System.Data.SqlClient;
using System.Threading.Tasks;

namespace Gestion.Colegial.DataAccess.Repositories
{
    public class KPIsFinancierosRepository : RepositoryBase, IKPIsFinancierosRepository
    {
        public async Task<Answer> Find(int Anio, int? Mes)
        {
            const string sql = "finanza.PR_KPIs_Financieros";
            SqlParameter[] parameters =
            {
                new SqlParameter { ParameterName = "@Anio", DbType = DbType.Int32, Value = Anio },
                new SqlParameter { ParameterName = "@Mes",  DbType = DbType.Int32, Value = (object)Mes ?? System.DBNull.Value },
            };
            return await Search<KPIsFinancierosResult>(sql, parameters);
        }
    }
}
