using Gestion.Colegial.Entities;
using Gestion.Colegial.Entities.Entities.app;
using Gestion.Colegial.Entities.Entities.dbo;
using System.Data;
using System.Data.SqlClient;

namespace Gestion.Colegial.DataAccess.Repositories
{
    public class HoraRepository : RepositoryBase
    {
        public async Task<Answer> List()
        {
            const string sql = "PR_tbHoras_List";
            Answer answer = await Read<PR_tbHoras_ListResult>(sql);
            return answer;
        }

        public async Task<Answer> Find(int id)
        {
            const string sql = "PR_tbHoras_Find";
            SqlParameter[] sqlParameters = {
                new SqlParameter() { ParameterName = "@Hor_Id", DbType = DbType.Int32, Value = id },
            };
            Answer answer = await Search<PR_tbHoras_FindResult>(sql, sqlParameters);
            return answer;
        }

        //public async Task<Answer> Detail(int id)
        //{
        //    const string sql = "PR_tbHoras_Detail";
        //    await db.SaveChangesAsync();
        //    if (resultado == null)
        //    {
        //        return null;
        //    }
        //    return resultado;
        //}

        public async Task<Answer> Create(tbHoras obj)
        {
            obj.Hor_UsuarioRegistra = 1;
            const string sql = "PR_tbHoras_Insert";
            SqlParameter[] sqlParameters = {
                new SqlParameter(){ParameterName= "@Hor_Hora", DbType = DbType.String , Value = obj.Hor_Hora},
                new SqlParameter(){ParameterName= "@Hor_UsuarioRegistra", DbType = DbType.Int32 , Value = obj.Hor_UsuarioRegistra}
            };
            Answer answer = await New(sql, sqlParameters);
            return answer;
        }

        public async Task<Answer> Edit(tbHoras obj)
        {
            obj.Hor_UsuarioModifica = 1;
            const string sql = "PR_tbHoras_Update";
            SqlParameter[] sqlParameters = {
                new SqlParameter(){ParameterName= "@Hor_Id", DbType = DbType.Int32, Value = obj.Hor_Id},
                new SqlParameter(){ParameterName= "@Hor_Hora", DbType = DbType.String , Value = obj.Hor_Hora},
                new SqlParameter(){ParameterName= "@Hor_UsuarioModifica", DbType = DbType.Int32 , Value = obj.Hor_UsuarioModifica}
            };
            Answer answer = await Update(sql, sqlParameters);
            return answer;
        }

        public async Task<Answer> Exist(string value)
        {
            const string sql = "PR_tbHoras_Exist";
            SqlParameter[] sqlParameters = {
                new SqlParameter(){ParameterName= "@Hor_Hora", DbType = DbType.String, Value = value}
            };
            Answer answer = await Exist<PR_tbHoras_ExistResult>(sql, sqlParameters);
            return answer;
        }

        public async Task<Answer> Delete(int id)
        {
            const string sql = "PR_tbHoras_Delete";
            SqlParameter[] sqlParameters = {
                new SqlParameter() { ParameterName = "@Hor_Id", DbType = DbType.Int32, Value = id },
            };
            Answer answer = await Delete(sql, sqlParameters);
            return answer;
        }
    }
}
