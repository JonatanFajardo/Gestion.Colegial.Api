using Gestion.Colegial.Entities;
using Gestion.Colegial.Entities.Entities.app;
using Gestion.Colegial.Entities.Entities.dbo;
using System.Data;
using System.Data.SqlClient;

namespace Gestion.Colegial.DataAccess.Repositories
{
    public class ParcialRepository : RepositoryBase
    {
        public async Task<Answer> List()
        {
            const string sql = "PR_tbParciales_List";
            Answer answer = await Read<PR_tbParciales_ListResult>(sql);
            return answer;
        }

        public async Task<Answer> Find(int id)
        {
            const string sql = "PR_tbParciales_Find";
            SqlParameter[] sqlParameters = {
                new SqlParameter() { ParameterName = "@Pac_Id", DbType = DbType.Int32, Value = id },
            };
            Answer answer = await Search<PR_tbParciales_FindResult>(sql, sqlParameters);
            return answer;
        }

        public async Task<Answer> Detail(int id)
        {
            const string sql = "PR_tbParciales_Detail";
            SqlParameter[] sqlParameters = {
                new SqlParameter() { ParameterName = "@Pac_Id", DbType = DbType.Int32, Value = id },
            };
            Answer answer = await Details<PR_tbParciales_DetailResult>(sql, sqlParameters, id);
            return answer;
        }

        public async Task<Answer> Create(tbParciales obj)
        {
            obj.Pac_UsuarioRegistra = 1;
            const string sql = "PR_tbParciales_Insert";
            SqlParameter[] sqlParameters = {
                new SqlParameter(){ParameterName= "@Pac_Descripcion", DbType = DbType.String, Value = obj.Pac_Descripcion},
                new SqlParameter(){ParameterName= "@Pac_UsuarioRegistra", DbType = DbType.Int32  , Value = obj.Pac_UsuarioRegistra}
            };
            Answer answer = await New(sql, sqlParameters);
            return answer;
        }

        public async Task<Answer> Edit(tbParciales obj)
        {
            obj.Pac_UsuarioModifica = 1;
            const string sql = "PR_tbParciales_Update";
            SqlParameter[] sqlParameters = {
                new SqlParameter(){ParameterName= "@Pac_Id", DbType = DbType.Int32, Value = obj.Pac_Id},
                new SqlParameter(){ParameterName= "@Pac_Descripcion", DbType = DbType.String, Value = obj.Pac_Descripcion},
                new SqlParameter(){ParameterName= "@Pac_UsuarioModifica", DbType = DbType.Int32, Value = obj.Pac_UsuarioModifica}
            };
            Answer answer = await Update(sql, sqlParameters);
            return answer;
        }

        public async Task<Answer> Exist(string value)
        {
            const string sql = "PR_tbParciales_Exist";
            SqlParameter[] sqlParameters = {
                new SqlParameter(){ParameterName= "@Pac_Descripcion", DbType = DbType.String, Value = value}
            };
            Answer answer = await Exist<PR_tbParciales_ExistResult>(sql, sqlParameters);
            return answer;
        }

        public async Task<Answer> Delete(int id)
        {
            const string sql = "PR_tbParciales_Delete";
            SqlParameter[] sqlParameters = {
                new SqlParameter() { ParameterName = "@Pac_Id", DbType = DbType.Int32, Value = id },
            };
            Answer answer = await Delete(sql, sqlParameters);
            return answer;
        }
    }
}
