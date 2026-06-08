using Gestion.Colegial.DataAccess.Interfaces;
using Gestion.Colegial.Entities;
using Gestion.Colegial.Entities.Entities;
using System.Data;
using System.Data.SqlClient;
using System.Threading.Tasks;

namespace Gestion.Colegial.DataAccess.Repositories
{
    public class NotificacionRepository : RepositoryBase, INotificacionRepository
    {
        public async Task<Answer> ListByUsuario(int usuId, bool soloNoLeidas)
        {
            const string sql = "app.PR_tbNotificaciones_ListByUsuario";
            SqlParameter[] parameters = {
                new SqlParameter { ParameterName = "@Usu_Id",       DbType = DbType.Int32,   Value = usuId },
                new SqlParameter { ParameterName = "@SoloNoLeidas", DbType = DbType.Boolean, Value = soloNoLeidas }
            };
            return await SearchAll<PR_tbNotificaciones_ListResult>(sql, parameters);
        }

        public async Task<Answer> MarcarLeida(int notId)
        {
            const string sql = "app.PR_tbNotificaciones_MarcarLeida";
            SqlParameter[] parameters = {
                new SqlParameter { ParameterName = "@Not_Id", DbType = DbType.Int32, Value = notId }
            };
            return await Update(sql, parameters);
        }

        public async Task<Answer> Insert(int usuId, string titulo, string mensaje, string tipo, string urlDestino, int usuarioRegistra)
        {
            const string sql = "app.PR_tbNotificaciones_Insert";
            SqlParameter[] parameters = {
                new SqlParameter { ParameterName = "@Usu_Id",              DbType = DbType.Int32,  Value = usuId },
                new SqlParameter { ParameterName = "@Not_Titulo",          DbType = DbType.String, Value = titulo },
                new SqlParameter { ParameterName = "@Not_Mensaje",         DbType = DbType.String, Value = mensaje },
                new SqlParameter { ParameterName = "@Not_Tipo",            DbType = DbType.String, Value = tipo ?? "I" },
                new SqlParameter { ParameterName = "@Not_UrlDestino",      DbType = DbType.String, Value = (object)urlDestino ?? DBNull.Value },
                new SqlParameter { ParameterName = "@Not_UsuarioRegistra", DbType = DbType.Int32,  Value = usuarioRegistra }
            };
            return await New(sql, parameters);
        }
    }
}
