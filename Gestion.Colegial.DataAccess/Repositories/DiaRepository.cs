using Gestion.Colegial.Entities;
using Gestion.Colegial.Entities.Entities.app;
using Gestion.Colegial.Entities.Entities.dbo;
using System.Data;
using System.Data.SqlClient;

namespace Gestion.Colegial.DataAccess.Repositories
{
    public class DiaRepository : RepositoryBase
    {
        public async Task<Answer> List()
        {
            const string sql = "PR_tbDias_List";
            Answer answer = await Read<PR_tbDias_ListResult>(sql);
            return answer;
        }

        public async Task<Answer> Find(int id)
        {
            const string sql = "PR_tbDias_Find";
            SqlParameter[] sqlParameters = {
                new SqlParameter() { ParameterName = "@Dia_Id", DbType = DbType.Int32, Value = id },
            };
            Answer answer = await Search<PR_tbDias_FindResult>(sql, sqlParameters);
            return answer;
        }

        public async Task<Answer> Detail(int id)
        {
            const string sql = "PR_tbDias_Detail";
            SqlParameter[] sqlParameters = {
                new SqlParameter() { ParameterName = "@Dia_Id", DbType = DbType.Int32, Value = id },
            };
            Answer answer = await Details<PR_tbDias_DetailResult>(sql, sqlParameters, id);
            return answer;
        }

        public async Task<Answer> Create(tbDias obj)
        {
            obj.Dia_UsuarioRegistra = 1;
            const string sql = "PR_tbDias_Insert";
            SqlParameter[] sqlParameters = {
                new SqlParameter(){ParameterName= "@Dia_Descripcion", DbType = DbType.String, Value = obj.Dia_Descripcion},
                new SqlParameter(){ParameterName= "@Dia_UsuarioRegistra", DbType = DbType.Int32  , Value = obj.Dia_UsuarioRegistra}
            };
            Answer answer = await New(sql, sqlParameters);
            return answer;
        }

        public async Task<Answer> Edit(tbDias obj)
        {
            obj.Dia_UsuarioModifica = 1;
            const string sql = "PR_tbDias_Update";
            SqlParameter[] sqlParameters = {
                new SqlParameter(){ParameterName= "@Dia_Id", DbType = DbType.Int32, Value = obj.Dia_Id},
                new SqlParameter(){ParameterName= "@Dia_Descripcion", DbType = DbType.String, Value = obj.Dia_Descripcion},
                new SqlParameter(){ParameterName= "@Dia_UsuarioModifica", DbType = DbType.Int32, Value = obj.Dia_UsuarioModifica}
            };
            Answer answer = await Update(sql, sqlParameters);
            return answer;
        }

        public async Task<Answer> Exist(string value)
        {
            const string sql = "PR_tbDias_Exist";
            SqlParameter[] sqlParameters = {
                new SqlParameter(){ParameterName= "@Dia_Descripcion", DbType = DbType.String, Value = value}
            };
            Answer answer = await Exist<PR_tbDias_ExistResult>(sql, sqlParameters);
            return answer;
        }

        public async Task<Answer> Delete(int id)
        {
            const string sql = "PR_tbDias_Delete";
            SqlParameter[] sqlParameters = {
                new SqlParameter() { ParameterName = "@Dia_Id", DbType = DbType.Int32, Value = id },
            };
            Answer answer = await Delete(sql, sqlParameters);
            return answer;
        }
    }
}