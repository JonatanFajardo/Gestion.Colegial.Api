using Gestion.Colegial.DataAccess.Interfaces;
using Gestion.Colegial.Entities;
using Gestion.Colegial.Entities.Entities;
using System.Data;
using System.Data.SqlClient;
using System.Threading.Tasks;

namespace Gestion.Colegial.DataAccess.Repositories
{
    public class BuscadorRepository : RepositoryBase, IBuscadorRepository
    {
        public async Task<Answer> Buscar(string busqueda)
        {
            const string sql = "app.PR_BuscadorGlobal";
            SqlParameter[] parameters = {
                new SqlParameter { ParameterName = "@Busqueda", DbType = DbType.String, Value = busqueda }
            };
            return await SearchAll<PR_BuscadorGlobal_ListResult>(sql, parameters);
        }
    }
}
