using Gestion.Colegial.Entities;
using Gestion.Colegial.Entities.Entities.app;
using Gestion.Colegial.Entities.Entities.dbo;
using System.Data;
using System.Data.SqlClient;

namespace Gestion.Colegial.DataAccess.Repositories
{
    public class DuracionRepository : RepositoryBase
    {
        public async Task<Answer> List()
        {
            const string sql = "PR_tbDuraciones_List";
            Answer answer = await Read<PR_tbDuraciones_ListResult>(sql);
            return answer;
        }

        public async Task<Answer> Find(int id)
        {
            const string sql = "PR_tbDuraciones_Find";
            SqlParameter[] sqlParameters = {
                new SqlParameter() { ParameterName = "@Dur_Id", DbType = DbType.Int32, Value = id },
            };
            Answer answer = await Search<PR_tbDuraciones_FindResult>(sql, sqlParameters);
            return answer;
        }

        public async Task<Answer> Detail(int id)
        {
            const string sql = "PR_tbDuraciones_Detail";
            SqlParameter[] sqlParameters = {
                new SqlParameter() { ParameterName = "@Dur_Id", DbType = DbType.Int32, Value = id },
            };
            Answer answer = await Details<PR_tbDuraciones_DetailResult>(sql, sqlParameters, id);
            return answer;
        }

        public async Task<Answer> Create(tbDuraciones obj)
        {
            obj.Dur_UsuarioRegistra = 1;
            const string sql = "PR_tbDuraciones_Insert";
            SqlParameter[] sqlParameters = {
                new SqlParameter(){ParameterName= "@Dur_Descripcion", DbType = DbType.String, Value = obj.Dur_Descripcion},
                new SqlParameter(){ParameterName= "@Dur_UsuarioRegistra", DbType = DbType.Int32  , Value = obj.Dur_UsuarioRegistra}
            };
            Answer answer = await New(sql, sqlParameters);
            return answer;
        }

        public async Task<Answer> Edit(tbDuraciones obj)
        {
            obj.Dur_UsuarioModifica = 1;
            const string sql = "PR_tbDuraciones_Update";
            SqlParameter[] sqlParameters = {
                new SqlParameter(){ParameterName= "@Dur_Id", DbType = DbType.Int32, Value = obj.Dur_Id},
                new SqlParameter(){ParameterName= "@Dur_Descripcion", DbType = DbType.String, Value = obj.Dur_Descripcion},
                new SqlParameter(){ParameterName= "@Dur_UsuarioModifica", DbType = DbType.Int32, Value = obj.Dur_UsuarioModifica}
            };
            Answer answer = await Update(sql, sqlParameters);
            return answer;
        }

        public async Task<Answer> Exist(string value)
        {
            const string sql = "PR_tbDuraciones_Exist";
            SqlParameter[] sqlParameters = {
                new SqlParameter(){ParameterName= "@Dur_Descripcion", DbType = DbType.String, Value = value}
            };
            Answer answer = await Exist<PR_tbDuraciones_ExistResult>(sql, sqlParameters);
            return answer;
        }

        public async Task<Answer> Delete(int id)
        {
            const string sql = "PR_tbDuraciones_Delete";
            SqlParameter[] sqlParameters = {
                new SqlParameter() { ParameterName = "@Dur_Id", DbType = DbType.Int32, Value = id },
            };
            Answer answer = await Delete(sql, sqlParameters);
            return answer;
        }
    }
}
