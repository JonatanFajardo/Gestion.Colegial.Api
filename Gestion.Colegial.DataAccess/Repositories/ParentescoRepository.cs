using Gestion.Colegial.Entities;
using Gestion.Colegial.Entities.Entities.app;
using Gestion.Colegial.Entities.Entities.dbo;
using System.Data;
using System.Data.SqlClient;

namespace Gestion.Colegial.DataAccess.Repositories
{
    public class ParentescoRepository : RepositoryBase
    {
        public async Task<Answer> List()
        {
            const string sql = "PR_tbParentescos_List";
            Answer answer = await Read<PR_tbParentescos_ListResult>(sql);
            return answer;
        }

        public async Task<Answer> Find(int id)
        {
            const string sql = "PR_tbParentescos_Find";
            SqlParameter[] sqlParameters = {
                new SqlParameter() { ParameterName = "@Par_Id", DbType = DbType.Int32, Value = id },
            };
            Answer answer = await Search<PR_tbParentescos_FindResult>(sql, sqlParameters);
            return answer;
        }

        public async Task<Answer> Detail(int id)
        {
            const string sql = "PR_tbParentescos_Detail";
            SqlParameter[] sqlParameters = {
                new SqlParameter() { ParameterName = "@Par_Id", DbType = DbType.Int32, Value = id },
            };
            Answer answer = await Details<PR_tbParentescos_DetailResult>(sql, sqlParameters, id);
            return answer;
        }

        public async Task<Answer> Create(tbParentescos obj)
        {
            obj.Par_UsuarioRegistra = 1;
            const string sql = "PR_tbParentescos_Insert";
            SqlParameter[] sqlParameters = {
                new SqlParameter(){ParameterName= "@Par_Descripcion", DbType = DbType.String, Value = obj.Par_Descripcion},
                new SqlParameter(){ParameterName= "@Par_UsuarioRegistra", DbType = DbType.Int32  , Value = obj.Par_UsuarioRegistra}
            };
            Answer answer = await New(sql, sqlParameters);
            return answer;
        }

        public async Task<Answer> Edit(tbParentescos obj)
        {
            obj.Par_UsuarioModifica = 1;
            const string sql = "PR_tbParentescos_Updat0e";
            SqlParameter[] sqlParameters = {
                new SqlParameter(){ParameterName= "@Par_Id", DbType = DbType.Int32, Value = obj.Par_Id},
                new SqlParameter(){ParameterName= "@Par_Descripcion", DbType = DbType.String, Value = obj.Par_Descripcion},
                new SqlParameter(){ParameterName= "@Par_UsuarioModifica", DbType = DbType.Int32, Value = obj.Par_UsuarioModifica}
            };
            Answer answer = await Update(sql, sqlParameters);
            return answer;
        }

        public async Task<Answer> Exist(string value)
        {
            const string sql = "PR_tbParentescos_Exist";
            SqlParameter[] sqlParameters = {
                new SqlParameter(){ParameterName= "@Par_Descripcion", DbType = DbType.String, Value = value}
            };
            Answer answer = await Exist<PR_tbParentescos_ExistResult>(sql, sqlParameters);
            return answer;
        }

        public async Task<Answer> Delete(int id)
        {
            const string sql = "PR_tbParentescos_Delete";
            SqlParameter[] sqlParameters = {
                new SqlParameter() { ParameterName = "@Par_Id", DbType = DbType.Int32, Value = id },
            };
            Answer answer = await Delete(sql, sqlParameters);
            return answer;
        }
    }
}