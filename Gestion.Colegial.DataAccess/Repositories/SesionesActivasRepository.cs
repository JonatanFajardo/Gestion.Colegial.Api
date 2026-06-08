using Gestion.Colegial.DataAccess.Interfaces;
using Gestion.Colegial.Entities;
using Gestion.Colegial.Entities.Entities;
using System.Data.SqlClient;
using System.Threading.Tasks;

namespace Gestion.Colegial.DataAccess.Repositories
{
    public class SesionesActivasRepository : RepositoryBase, ISesionesActivasRepository
    {
        public async Task<Answer> List()
        {
            const string sql = "Seguridad.PR_SesionesActivas_List";
            SqlParameter[] parameters = { };
            return await SearchAll<SesionesActivasResult>(sql, parameters);
        }
    }
}
