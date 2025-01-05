using Gestion.Colegial.Entities;
using Gestion.Colegial.Entities.Entities;
using System.Data;
using System.Data.SqlClient;


namespace Gestion.Colegial.DataAccess.Repositories
{
    public class CursoNivelRepository : RepositoryBase
    {
        public async Task<Answer> List()
        {
            const string sql = "PR_tbCursosNiveles_List";
            Answer answer = await Read<PR_tbCursosNiveles_ListResult>(sql);
            return answer;
        }

        public async Task<Answer> Find(int id)
        {
            const string sql = "PR_tbCursosNiveles_Find";
            SqlParameter[] sqlParameters = {
                new SqlParameter() { ParameterName = "@Cun_Id", DbType = DbType.Int32, Value = id },
            };
            Answer answer = await Search<PR_tbCursosNiveles_FindResult>(sql, sqlParameters);
            return answer;
        }

        public async Task<Answer> Detail(int id)
        {
            const string sql = "PR_tbCursosNiveles_Detail";
            SqlParameter[] sqlParameters = {
                new SqlParameter() { ParameterName = "@Cun_Id", DbType = DbType.Int32, Value = id },
            };
            Answer answer = await Details<PR_tbCursosNiveles_DetailResult>(sql, sqlParameters, id);
            return answer;
        }

        public async Task<Answer> Create(tbCursosNiveles obj)
        {
            obj.Cun_UsuarioRegistra = 1;
            const string sql = "PR_tbCursosNiveles_Insert";
            SqlParameter[] sqlParameters = {
                new SqlParameter(){ParameterName= "@Cun_Descripcion", DbType = DbType.String, Value = obj.Cun_Descripcion},
                new SqlParameter(){ParameterName= "@Cun_UsuarioRegistra", DbType = DbType.Int32  , Value = obj.Cun_UsuarioRegistra}
            };
            Answer answer = await New(sql, sqlParameters);
            return answer;
        }

        public async Task<Answer> Edit(tbCursosNiveles obj)
        {
            obj.Cun_UsuarioModifica = 1;

            const string sql = "PR_tbCursosNiveles_Update";
            SqlParameter[] sqlParameters = {
                new SqlParameter(){ParameterName= "@Cun_Id", DbType = DbType.Int32, Value = obj.Cun_Id},
                new SqlParameter(){ParameterName= "@Cun_Descripcion", DbType = DbType.String, Value = obj.Cun_Descripcion},
                new SqlParameter(){ParameterName= "@Cun_UsuarioModifica", DbType = DbType.Int32, Value = obj.Cun_UsuarioModifica}
            };
            Answer answer = await Update(sql, sqlParameters);
            return answer;
        }

        public async Task<Answer> Exist(string value)
        {
            const string sql = "PR_tbCursosNiveles_Exist";
            SqlParameter[] sqlParameters = {
                new SqlParameter(){ParameterName= "@Cun_Descripcion", DbType = DbType.String, Value = value}
            };
            Answer answer = await Exist<PR_tbCursosNiveles_ExistResult>(sql, sqlParameters);
            return answer;
        }

        public async Task<Answer> Delete(int id)
        {
            const string sql = "PR_tbCursosNiveles_Delete";
            SqlParameter[] sqlParameters = {
                new SqlParameter() { ParameterName = "@Cun_Id", DbType = DbType.Int32, Value = id },
            };
            Answer answer = await Delete(sql, sqlParameters);
            return answer;
        }
    }
}
