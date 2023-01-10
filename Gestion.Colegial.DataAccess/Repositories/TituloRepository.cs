using Gestion.Colegial.Entities;
using Gestion.Colegial.Entities.Entities.app;
using Gestion.Colegial.Entities.Entities.dbo;
using System.Data;
using System.Data.SqlClient;

namespace Gestion.Colegial.DataAccess.Repositories
{
    public class TituloRepository : RepositoryBase
    {
        public async Task<Answer> List()
        {
            const string sql = "PR_tbTitulos_List";
            Answer answer = await Read<PR_tbTitulos_ListResult>(sql);
            return answer;
        }

        public async Task<Answer> Find(int id)
        {
            const string sql = "PR_tbTitulos_Find";
            SqlParameter[] sqlParameters = {
                new SqlParameter() { ParameterName = "@Tit_Id", DbType = DbType.Int32, Value = id },
            };
            Answer answer = await Search<PR_tbTitulos_FindResult>(sql, sqlParameters);
            return answer;
        }

        public async Task<Answer> Detail(int id)
        {
            const string sql = "PR_tbTitulos_Detail";
            SqlParameter[] sqlParameters = {
                new SqlParameter() { ParameterName = "@Tit_Id", DbType = DbType.Int32, Value = id },
            };
            Answer answer = await Details<PR_tbTitulos_DetailResult>(sql, sqlParameters, id);
            return answer;
        }

        public async Task<Answer> Create(tbTitulos obj)
        {
            obj.Tit_UsuarioRegistra = 1;
            const string sql = "PR_tbTitulos_Insert";
            SqlParameter[] sqlParameters = {
                new SqlParameter(){ParameterName= "@Tit_Descripcion", DbType = DbType.String, Value = obj.Tit_Descripcion},
                new SqlParameter(){ParameterName= "@Tit_UsuarioRegistra", DbType = DbType.Int32  , Value = obj.Tit_UsuarioRegistra}
            };
            Answer answer = await New(sql, sqlParameters);
            return answer;
        }

        public async Task<Answer> Edit(tbTitulos obj)
        {
            obj.Tit_UsuarioModifica = 1;
            const string sql = "PR_tbTitulos_Update";
            SqlParameter[] sqlParameters = {
                new SqlParameter(){ParameterName= "@Tit_Id", DbType = DbType.Int32, Value = obj.Tit_Id},
                new SqlParameter(){ParameterName= "@Tit_Descripcion", DbType = DbType.String, Value = obj.Tit_Descripcion},
                new SqlParameter(){ParameterName= "@Tit_UsuarioModifica", DbType = DbType.Int32, Value = obj.Tit_UsuarioModifica}
            };
            Answer answer = await Update(sql, sqlParameters);
            return answer;
        }

        public async Task<Answer> Exist(string value)
        {
            const string sql = "PR_tbTitulos_Exist";
            SqlParameter[] sqlParameters = {
                new SqlParameter(){ParameterName= "@Tit_Descripcion", DbType = DbType.String, Value = value}
            };
            Answer answer = await Exist<PR_tbTitulos_ExistResult>(sql, sqlParameters);
            return answer;
        }

        public async Task<Answer> Delete(int id)
        {
            const string sql = "PR_tbTitulos_Delete";
            SqlParameter[] sqlParameters = {
                new SqlParameter() { ParameterName = "@Tit_Id", DbType = DbType.Int32, Value = id },
            };
            Answer answer = await Delete(sql, sqlParameters);
            return answer;
        }
    }
}