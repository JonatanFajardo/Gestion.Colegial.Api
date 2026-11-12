using Gestion.Colegial.DataAccess.Interfaces;
using Gestion.Colegial.Entities;
using Gestion.Colegial.Entities.Entities;
using System.Data;
using System.Data.SqlClient;
using System.Threading.Tasks;

namespace Gestion.Colegial.DataAccess.Repositories
{
    public class MensajesRepository : RepositoryBase, IMensajesRepository
    {
        public async Task<Answer> List(int? Alu_Id, int? UsuarioId)
        {
            const string sql = "app.PR_Mensajes_List";
            SqlParameter[] parameters =
            {
                new SqlParameter { ParameterName = "@Alu_Id",    DbType = DbType.Int32, Value = (object)Alu_Id    ?? DBNull.Value },
                new SqlParameter { ParameterName = "@UsuarioId", DbType = DbType.Int32, Value = (object)UsuarioId ?? DBNull.Value },
            };
            return await SearchAll<PR_Mensajes_ListResult>(sql, parameters);
        }

        public async Task<Answer> Insert(string Msg_Asunto, string Msg_Contenido, int Alu_Id, int UsuarioEnvia)
        {
            const string sql = "app.PR_Mensajes_Insert";
            SqlParameter[] parameters =
            {
                new SqlParameter { ParameterName = "@Msg_Asunto",    DbType = DbType.String, Value = Msg_Asunto    },
                new SqlParameter { ParameterName = "@Msg_Contenido", DbType = DbType.String, Value = Msg_Contenido },
                new SqlParameter { ParameterName = "@Alu_Id",        DbType = DbType.Int32,  Value = Alu_Id        },
                new SqlParameter { ParameterName = "@UsuarioEnvia",  DbType = DbType.Int32,  Value = UsuarioEnvia  },
            };
            return await New(sql, parameters);
        }

        public async Task<Answer> Delete(int Msg_Id, int UsuarioModifica)
        {
            const string sql = "app.PR_Mensajes_Delete";
            SqlParameter[] parameters =
            {
                new SqlParameter { ParameterName = "@Msg_Id",          DbType = DbType.Int32, Value = Msg_Id          },
                new SqlParameter { ParameterName = "@UsuarioModifica",  DbType = DbType.Int32, Value = UsuarioModifica  },
            };
            return await Delete(sql, parameters);
        }
    }
}
