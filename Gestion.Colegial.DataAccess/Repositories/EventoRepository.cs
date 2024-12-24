using Gestion.Colegial.Entities;
using Gestion.Colegial.Entities.Entities.app;
using Gestion.Colegial.Entities.Entities.dbo;
using System.Data;
using System.Data.SqlClient;

namespace Gestion.Colegial.DataAccess.Repositories
{
    public class EventoRepository : RepositoryBase
    {
        public async Task<Answer> List()
        {
            const string sql = "PR_tbEventos_List";
            Answer answer = await Read<PR_tbEventos_ListResult>(sql);
            return answer;
        }

        public async Task<Answer> Find(int id)
        {
            const string sql = "PR_tbEventos_Find";
            SqlParameter[] sqlParameters = {
                new SqlParameter() { ParameterName = "@even_Id", DbType = DbType.Int32, Value = id },
            };
            Answer answer = await Search<PR_tbEventos_FindResult>(sql, sqlParameters);
            return answer;
        }

        public async Task<Answer> Detail(int id)
        {
            const string sql = "PR_tbEventos_Detail";
            SqlParameter[] sqlParameters = {
                new SqlParameter() { ParameterName = "@even_Id", DbType = DbType.Int32, Value = id },
            };
            Answer answer = await Details<PR_tbEventos_DetailResult>(sql, sqlParameters, id);
            return answer;
        }

        public async Task<Answer> Create(tbEventos obj)
        {
            obj.even_UsuarioRegistra = 1;
            const string sql = "PR_tbEventos_Insert";
            SqlParameter[] sqlParameters = {
                new SqlParameter(){ParameterName= "@even_Id", DbType = DbType.String, Value = obj.even_Id},
                new SqlParameter(){ParameterName= "@even_Nombre", DbType = DbType.String, Value = obj.even_Nombre},
                new SqlParameter(){ParameterName= "@even_Informacion", DbType = DbType.String, Value = obj.even_Informacion},
                new SqlParameter(){ParameterName= "@even_Fecha", DbType = DbType.String, Value = obj.even_Fecha},
                new SqlParameter(){ParameterName= "@even_Hora", DbType = DbType.String, Value = obj.even_Hora},
                new SqlParameter(){ParameterName= "@even_Concluido", DbType = DbType.Boolean, Value = obj.even_Concluido},
                new SqlParameter(){ParameterName= "@even_UsuarioRegistra", DbType = DbType.Int32  , Value = obj.even_UsuarioRegistra}
            };
            Answer answer = await New(sql, sqlParameters);
            return answer;
        }

        public async Task<Answer> Edit(tbEventos obj)
        {
            obj.even_UsuarioModifica = 1;
            const string sql = "PR_tbEventos_Update";
            SqlParameter[] sqlParameters = {
                new SqlParameter(){ParameterName= "@even_Id", DbType = DbType.Int32, Value = obj.even_Id},
                new SqlParameter(){ParameterName= "@even_Nombre", DbType = DbType.String, Value = obj.even_Nombre},
                new SqlParameter(){ParameterName= "@even_Informacion", DbType = DbType.String, Value = obj.even_Informacion},
                new SqlParameter(){ParameterName= "@even_Fecha", DbType = DbType.Date, Value = obj.even_Fecha},
                new SqlParameter(){ParameterName= "@even_Hora", DbType = DbType.Time, Value = obj.even_Hora},
                new SqlParameter(){ParameterName= "@even_Concluido", DbType = DbType.Boolean, Value = obj.even_Concluido},
                new SqlParameter(){ParameterName= "@even_UsuarioModifica", DbType = DbType.Int32, Value = obj.even_UsuarioModifica}
            };
            Answer answer = await Update(sql, sqlParameters);
            return answer;
        }

        public async Task<Answer> Delete(int id)
        {
            const string sql = "PR_tbEventos_Delete";
            SqlParameter[] sqlParameters = {
                new SqlParameter() { ParameterName = "@even_Id", DbType = DbType.Int32, Value = id },
            };
            Answer answer = await Delete(sql, sqlParameters);
            return answer;
        }
    }
}
