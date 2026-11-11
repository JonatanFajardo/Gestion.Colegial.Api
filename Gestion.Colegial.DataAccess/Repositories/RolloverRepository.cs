using Gestion.Colegial.DataAccess.Interfaces;
using Gestion.Colegial.Entities;
using Gestion.Colegial.Entities.Entities;
using System.Data;
using System.Data.SqlClient;

namespace Gestion.Colegial.DataAccess.Repositories
{
    public class RolloverRepository : RepositoryBase, IRolloverRepository
    {
        public async Task<Answer> RollForward(int origen, int destino)
        {
            const string sql = "app.PR_tbAnioLectivo_RollForward";
            SqlParameter[] sqlParameters = {
                new SqlParameter(){ParameterName= "@Ani_Origen",  DbType = DbType.Int32, Value = origen },
                new SqlParameter(){ParameterName= "@Ani_Destino", DbType = DbType.Int32, Value = destino },
            };
            Answer answer = await Search<PR_RollForwardResult>(sql, sqlParameters);
            return answer;
        }
    }
}
