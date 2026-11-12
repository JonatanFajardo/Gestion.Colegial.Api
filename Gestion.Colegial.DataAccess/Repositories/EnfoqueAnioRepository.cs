using Gestion.Colegial.DataAccess.Interfaces;
using Gestion.Colegial.Entities;
using Gestion.Colegial.Entities.Entities;
using System.Data;
using System.Data.SqlClient;

namespace Gestion.Colegial.DataAccess.Repositories
{
    public class EnfoqueAnioRepository : RepositoryBase, IEnfoqueAnioRepository
    {
        public async Task<Answer> Find(int id)
        {
            const string sql = "app.PR_tbEnfoqueAnio_Find";
            SqlParameter[] sqlParameters = {
                new SqlParameter(){ParameterName= "@value", DbType = DbType.Int32, Value = id },
            };
            Answer answer = await Search<PR_tbEnfoqueAnio_FindResult>(sql, sqlParameters);
            return answer;
        }

        public async Task<Answer> Set(tbEnfoqueAnio obj)
        {
            const string sql = "app.PR_tbEnfoqueAnio_Set";
            SqlParameter[] sqlParameters = {
                new SqlParameter(){ParameterName= "@Ani_Id", DbType = DbType.Int32, Value = obj.Ani_Id },
                new SqlParameter(){ParameterName= "@Enf_Modelo", DbType = DbType.String, Value = (object)obj.Enf_Modelo ?? DBNull.Value },
                new SqlParameter(){ParameterName= "@Enf_Razon", DbType = DbType.String, Value = (object)obj.Enf_Razon ?? DBNull.Value },
            };
            Answer answer = await Update(sql, sqlParameters);
            return answer;
        }
    }
}
