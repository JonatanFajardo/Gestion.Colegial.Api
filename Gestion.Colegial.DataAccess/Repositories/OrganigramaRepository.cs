using Gestion.Colegial.DataAccess.Interfaces;
using Gestion.Colegial.Entities;
using Gestion.Colegial.Entities.Entities;
using System.Data.SqlClient;

namespace Gestion.Colegial.DataAccess.Repositories
{
    public class OrganigramaRepository : RepositoryBase, IOrganigramaRepository
    {
        public async Task<Answer> Get()
        {
            const string sql = "app.PR_Organigrama_GetTree";
            SqlParameter[] parameters = { };
            return await SearchAll<PR_Organigrama_GetTreeResult>(sql, parameters);
        }
    }
}
