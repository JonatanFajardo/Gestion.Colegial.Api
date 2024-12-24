using Gestion.Colegial.Entities;
using Gestion.Colegial.Entities.Entities.app;
using Gestion.Colegial.Entities.Entities.dbo;
using System.Data;
using System.Data.SqlClient;

namespace Gestion.Colegial.DataAccess.Repositories
{
    public class EstadoRepository : RepositoryBase
    {
        public async Task<Answer> List()
        {
            const string sql = "PR_tbEstados_List";
            Answer answer = await Read<PR_tbEstados_ListResult>(sql);
            return answer;
        }

        public async Task<Answer> Find(int id)
        {
            const string sql = "PR_tbEstados_Find";
            SqlParameter[] sqlParameters = {
                new SqlParameter() { ParameterName = "@Est_Id", DbType = DbType.Int32, Value = id },
            };
            Answer answer = await Search<PR_tbEstados_FindResult>(sql, sqlParameters);
            return answer;
        }

        public async Task<Answer> Detail(int id)
        {
            const string sql = "PR_tbEstados_Detail";
            SqlParameter[] sqlParameters = {
                new SqlParameter() { ParameterName = "@Est_Id", DbType = DbType.Int32, Value = id },
            };
            Answer answer = await Details<PR_tbEstados_DetailResult>(sql, sqlParameters, id);
            return answer;
        }

        public async Task<Answer> Create(tbEstados obj)
        {
            obj.Est_UsuarioRegistra = 1;
            const string sql = "PR_tbEstados_Insert";
            SqlParameter[] sqlParameters = {
                new SqlParameter(){ParameterName= "@Est_Descripcion", DbType = DbType.String, Value = obj.Est_Descripcion},
                new SqlParameter(){ParameterName= "@Est_UsuarioRegistra", DbType = DbType.Int32  , Value = obj.Est_UsuarioRegistra}
            };
            Answer answer = await New(sql, sqlParameters);
            return answer;
        }

        public async Task<Answer> Edit(tbEstados obj)
        {
            obj.Est_UsuarioModifica = 1;
            const string sql = "PR_tbEstados_Update";
            SqlParameter[] sqlParameters = {
                new SqlParameter(){ParameterName= "@Est_Id", DbType = DbType.Int32, Value = obj.Est_Id},
                new SqlParameter(){ParameterName= "@Est_Descripcion", DbType = DbType.String, Value = obj.Est_Descripcion},
                new SqlParameter(){ParameterName= "@Est_UsuarioModifica", DbType = DbType.Int32, Value = obj.Est_UsuarioModifica}
            };
            Answer answer = await Update(sql, sqlParameters);
            return answer;
        }

        public async Task<Answer> Exist(string value)
        {
            const string sql = "PR_tbEstados_Exist";
            SqlParameter[] sqlParameters = {
                new SqlParameter(){ParameterName= "@Est_Descripcion", DbType = DbType.String, Value = value}
            };
            Answer answer = await Exist<PR_tbEstados_ExistResult>(sql, sqlParameters);
            return answer;
        }

        public async Task<Answer> Delete(int id)
        {
            const string sql = "PR_tbEstados_Delete";
            SqlParameter[] sqlParameters = {
                new SqlParameter() { ParameterName = "@Est_Id", DbType = DbType.Int32, Value = id },
            };
            Answer answer = await Delete(sql, sqlParameters);
            return answer;
        }
    }
}
