using Gestion.Colegial.DataAccess.Interfaces;
using Gestion.Colegial.Entities;
using Gestion.Colegial.Entities.Entities;
using System.Data;
using System.Data.SqlClient;
using System.Threading.Tasks;

namespace Gestion.Colegial.DataAccess.Repositories
{
    public class ComparativoAniosRepository : RepositoryBase, IComparativoAniosRepository
    {
        public async Task<Answer> List(int AnioBase, int AnioComparacion)
        {
            const string sql = "app.PR_Academico_ComparativoAnios";
            SqlParameter[] parameters =
            {
                new SqlParameter { ParameterName = "@AnioBase",        DbType = DbType.Int32, Value = AnioBase },
                new SqlParameter { ParameterName = "@AnioComparacion", DbType = DbType.Int32, Value = AnioComparacion },
            };
            return await SearchAll<ComparativoAniosResult>(sql, parameters);
        }
    }
}
