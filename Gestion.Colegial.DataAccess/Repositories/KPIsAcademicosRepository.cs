using Gestion.Colegial.DataAccess.Interfaces;
using Gestion.Colegial.Entities;
using Gestion.Colegial.Entities.Entities;
using System.Data;
using System.Data.SqlClient;
using System.Threading.Tasks;

namespace Gestion.Colegial.DataAccess.Repositories
{
    public class KPIsAcademicosRepository : RepositoryBase, IKPIsAcademicosRepository
    {
        public async Task<Answer> Find(int Anio)
        {
            const string sql = "app.PR_KPIs_Academicos";
            SqlParameter[] parameters =
            {
                new SqlParameter { ParameterName = "@Anio", DbType = DbType.Int32, Value = Anio },
            };
            return await Search<KPIsAcademicosResult>(sql, parameters);
        }
    }
}
