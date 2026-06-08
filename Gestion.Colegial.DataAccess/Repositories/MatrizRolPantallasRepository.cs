using Gestion.Colegial.DataAccess.Interfaces;
using Gestion.Colegial.Entities;
using Gestion.Colegial.Entities.Entities;
using System.Data.SqlClient;
using System.Threading.Tasks;

namespace Gestion.Colegial.DataAccess.Repositories
{
    public class MatrizRolPantallasRepository : RepositoryBase, IMatrizRolPantallasRepository
    {
        public async Task<Answer> Get()
        {
            const string sql = "Seguridad.PR_MatrizRolPantallas_Get";
            SqlParameter[] parameters = { };
            return await SearchAll<MatrizRolPantallasResult>(sql, parameters);
        }
    }
}
