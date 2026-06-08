using Gestion.Colegial.DataAccess.Interfaces;
using Gestion.Colegial.Entities;
using Gestion.Colegial.Entities.Entities;
using System.Data;
using System.Data.SqlClient;
using System.Threading.Tasks;

namespace Gestion.Colegial.DataAccess.Repositories
{
    public class PerfilRepository : RepositoryBase, IPerfilRepository
    {
        public async Task<Answer> Find(int usuId)
        {
            const string sql = "seguridad.UDP_tbUsuarios_Perfil";
            SqlParameter[] parameters = {
                new SqlParameter { ParameterName = "@Usu_Id", DbType = DbType.Int32, Value = usuId }
            };
            return await Search<UDP_tbUsuarios_PerfilResult>(sql, parameters);
        }
    }
}
