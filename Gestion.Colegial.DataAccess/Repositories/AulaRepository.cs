using Gestion.Colegial.Entities;
using Gestion.Colegial.Entities.Entities;
using System.Data;
using System.Data.SqlClient;

namespace Gestion.Colegial.DataAccess.Repositories
{
    public class AulaRepository : RepositoryBase
    {
        public async Task<Answer> List()
        {
            const string sql = "PR_tbAulas_List";
            Answer answer = await Read<PR_tbAulas_ListResult>(sql);
            return answer;
        }

        public async Task<Answer> Find(int id)
        {
            const string sql = "PR_tbAulas_Find";
            SqlParameter[] sqlParameters = {
                new SqlParameter() { ParameterName = "@Aul_Id", DbType = DbType.Int32, Value = id },
            };
            Answer answer = await Search<PR_tbAulas_FindResult>(sql, sqlParameters);
            return answer;
        }

        public async Task<Answer> Detail(int id)
        {
            const string sql = "PR_tbAulas_Detail";
            SqlParameter[] sqlParameters = {
                new SqlParameter() { ParameterName = "@Aul_Id", DbType = DbType.Int32, Value = id },
            };
            Answer answer = await Details<PR_tbAulas_DetailResult>(sql, sqlParameters, id);
            return answer;
        }

        public async Task<Answer> Create(tbAulas obj)
        {
            obj.Aul_UsuarioRegistra = 1;
            const string sql = "PR_tbAulas_Insert";
            SqlParameter[] sqlParameters = {
                new SqlParameter(){ParameterName= "@Aul_Descripcion", DbType = DbType.String, Value = obj.Aul_Descripcion},
                new SqlParameter(){ParameterName= "@Aul_UsuarioRegistra", DbType = DbType.Int32  , Value = obj.Aul_UsuarioRegistra}
            };
            Answer answer = await New(sql, sqlParameters);
            return answer;
        }

        public async Task<Answer> Edit(tbAulas obj)
        {
            obj.Aul_UsuarioModifica = 1;
            const string sql = "PR_tbAulas_Update";
            SqlParameter[] sqlParameters = {
                new SqlParameter(){ParameterName= "@Aul_Id", DbType = DbType.Int32, Value = obj.Aul_Id},
                new SqlParameter(){ParameterName= "@Aul_Descripcion", DbType = DbType.String, Value = obj.Aul_Descripcion},
                new SqlParameter(){ParameterName= "@Aul_UsuarioModifica", DbType = DbType.Int32, Value = obj.Aul_UsuarioModifica}
            };
            Answer answer = await Update(sql, sqlParameters);
            return answer;
        }

        //public async Task<PR_tbAulas_ExistResult> Exist(string value)
        //{
        //    const string sql = "PR_tbAulas_Exist";
        //    await db.SaveChangesAsync();
        //    if (resultado == null)
        //    {
        //        return null;
        //    }
        //    return resultado;
        //}

        public async Task<Answer> Delete(int id)
        {
            const string sql = "PR_tbAulas_Delete";
            SqlParameter[] sqlParameters = {
                new SqlParameter() { ParameterName = "@Aul_Id", DbType = DbType.Int32, Value = id },
            };
            Answer answer = await Delete(sql, sqlParameters);
            return answer;
        }
    }
}
