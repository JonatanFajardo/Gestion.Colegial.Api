using Gestion.Colegial.Entities;
using Gestion.Colegial.Entities.Entities.app;
using Gestion.Colegial.Entities.Entities.dbo;
using System.Data;
using System.Data.SqlClient;

using System.Threading.Tasks;
using Gestion.Colegial.DataAccess.Repositories;

namespace Gestion.Colegial.DataAccess.Repositories
{
    public class SeccionRepository : RepositoryBase
    {
        public async Task<Answer> List()
        {
            const string sql = "PR_tbSecciones_List";
            Answer answer = await Read<PR_tbSecciones_ListResult>(sql);
            return answer;
        }

        public async Task<Answer> Find(int id)
        {
            const string sql = "PR_tbSecciones_Find";
            SqlParameter[] sqlParameters = {
                new SqlParameter() { ParameterName = "@Sec_Id", DbType = DbType.Int32, Value = id },
            };
            Answer answer = await Search<PR_tbSecciones_FindResult>(sql, sqlParameters);
            return answer;
        }

        public async Task<Answer> Detail(int id)
        {
            const string sql = "PR_tbSecciones_Detail";
            SqlParameter[] sqlParameters = {
                new SqlParameter() { ParameterName = "@Sec_Id", DbType = DbType.Int32, Value = id },
            };
            Answer answer = await Details<PR_tbSecciones_DetailResult>(sql, sqlParameters, id);
            return answer;
        }

        public async Task<Answer> Create(tbSecciones obj)
        {
            obj.Sec_UsuarioRegistra = 1;
            const string sql = "PR_tbSecciones_Insert";
            SqlParameter[] sqlParameters = {
                new SqlParameter(){ParameterName= "@Sec_Descripcion", DbType = DbType.String, Value = obj.Sec_Descripcion},
                new SqlParameter(){ParameterName= "@Sec_UsuarioRegistra", DbType = DbType.Int32  , Value = obj.Sec_UsuarioRegistra}
            };
            Answer answer = await New(sql, sqlParameters);
            return answer;
        }

        public async Task<Answer> Edit(tbSecciones obj)
        {
            obj.Sec_UsuarioModifica = 1;
            const string sql = "PR_tbSecciones_Update";
            SqlParameter[] sqlParameters = {
                new SqlParameter(){ParameterName= "@Sec_Id", DbType = DbType.Int32, Value = obj.Sec_Id},
                new SqlParameter(){ParameterName= "@Sec_Descripcion", DbType = DbType.String, Value = obj.Sec_Descripcion},
                new SqlParameter(){ParameterName= "@Sec_UsuarioModifica", DbType = DbType.Int32, Value = obj.Sec_UsuarioModifica}
            };
            Answer answer = await Update(sql, sqlParameters);
            return answer;
        }

        public async Task<Answer> Exist(string value)
        {
            const string sql = "PR_tbSecciones_Exist"; SqlParameter[] sqlParameters = {
                new SqlParameter(){ParameterName= "@Sec_Descripcion", DbType = DbType.String, Value = value}
            };
            Answer answer = await Exist<PR_tbSecciones_ExistResult>(sql, sqlParameters);
            return answer;
        }

        public async Task<Answer> Delete(int id)
        {
            const string sql = "PR_tbSecciones_Delete";
            SqlParameter[] sqlParameters = {
                new SqlParameter() { ParameterName = "@Sec_Id", DbType = DbType.Int32, Value = id },
            };
            Answer answer = await Delete(sql, sqlParameters);
            return answer;
        }
    }
}
