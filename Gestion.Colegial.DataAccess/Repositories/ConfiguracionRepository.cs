using Gestion.Colegial.DataAccess.Interfaces;
using Gestion.Colegial.Entities;
using Gestion.Colegial.Entities.Entities;
using System.Data;
using System.Data.SqlClient;
using System.Threading.Tasks;

namespace Gestion.Colegial.DataAccess.Repositories
{
    public class ConfiguracionRepository : RepositoryBase, IConfiguracionRepository
    {
        public async Task<Answer> List()
        {
            const string sql = "app.PR_Configuracion_List";
            return await SearchAll<PR_Configuracion_ListResult>(sql, new SqlParameter[0]);
        }

        public async Task<Answer> Update(int Con_Id, string Con_Valor, int UsuarioModifica)
        {
            const string sql = "app.PR_Configuracion_Update";
            SqlParameter[] parameters =
            {
                new SqlParameter { ParameterName = "@Con_Id",          DbType = DbType.Int32,  Value = Con_Id },
                new SqlParameter { ParameterName = "@Con_Valor",       DbType = DbType.String, Value = (object)Con_Valor ?? System.DBNull.Value },
                new SqlParameter { ParameterName = "@UsuarioModifica", DbType = DbType.Int32,  Value = UsuarioModifica },
            };
            return await Update(sql, parameters);
        }
    }
}
