using Gestion.Colegial.Entities;
using Gestion.Colegial.Entities.Entities.app;
using Gestion.Colegial.Entities.Entities.dbo;
using System.Data;
using System.Data.SqlClient;

namespace Gestion.Colegial.DataAccess.Repositories
{
    public class MateriaRepository : RepositoryBase
    {
        public async Task<Answer> List()
        {
            const string sql = "PR_tbMaterias_List";
            Answer answer = await Read<PR_tbMaterias_ListResult>(sql);
            return answer;
        }

        public async Task<Answer> Find(int id)
        {
            const string sql = "PR_tbMaterias_Find";
            SqlParameter[] sqlParameters = {
                new SqlParameter() { ParameterName = "@Mat_Id", DbType = DbType.Int32, Value = id },
            };
            Answer answer = await Search<PR_tbMaterias_FindResult>(sql, sqlParameters);
            return answer;
        }

        public async Task<Answer> Detail(int id)
        {
            const string sql = "PR_tbMaterias_Detail";
            SqlParameter[] sqlParameters = {
                new SqlParameter() { ParameterName = "@Mat_Id", DbType = DbType.Int32, Value = id },
            };
            Answer answer = await Details<PR_tbMaterias_DetailResult>(sql, sqlParameters, id);
            return answer;
        }

        public async Task<Answer> Create(tbMaterias obj)
        {
            obj.Mat_UsuarioRegistra = 1;
            const string sql = "PR_tbMaterias_Insert";
            SqlParameter[] sqlParameters = {
                new SqlParameter(){ParameterName= "@Mat_Nombre", DbType = DbType.String, Value = obj.Mat_Nombre},
                new SqlParameter(){ParameterName= "@Dur_Id", DbType = DbType.Int32, Value = obj.Dur_Id},
                new SqlParameter(){ParameterName= "@Mat_UsuarioRegistra", DbType = DbType.Int32  , Value = obj.Mat_UsuarioRegistra}
            };
            Answer answer = await New(sql, sqlParameters);
            return answer;
        }

        public async Task<Answer> Edit(tbMaterias obj)
        {
            obj.Mat_UsuarioModifica = 1;
            const string sql = "PR_tbMaterias_Update";
            SqlParameter[] sqlParameters = {
                new SqlParameter(){ParameterName= "@Mat_Id", DbType = DbType.Int32, Value = obj.Mat_Id},
                new SqlParameter(){ParameterName= "@Mat_Nombre", DbType = DbType.String, Value = obj.Mat_Nombre},
                new SqlParameter(){ParameterName= "@Dur_Id", DbType = DbType.Int32, Value = obj.Dur_Id},
                new SqlParameter(){ParameterName= "@Mat_EsActivo", DbType = DbType.Boolean, Value = obj.Mat_EsActivo},
                new SqlParameter(){ParameterName= "@Mat_UsuarioModifica", DbType = DbType.Int32  , Value = obj.Mat_UsuarioModifica}
            };
            Answer answer = await New(sql, sqlParameters);
            return answer;
        }

        public async Task<Answer> Exist(string value)
        {
            const string sql = "PR_tbMaterias_Exist";
            SqlParameter[] sqlParameters = {
                new SqlParameter(){ParameterName= "@Mat_Nombre", DbType = DbType.String, Value = value}
            };
            Answer answer = await Exist<PR_tbMaterias_ExistResult>(sql, sqlParameters);
            return answer;
        }

        public async Task<Answer> Delete(int id)
        {
            const string sql = "PR_tbMaterias_Delete";
            SqlParameter[] sqlParameters = {
                new SqlParameter() { ParameterName = "@Mat_Id", DbType = DbType.Int32, Value = id },
            };
            Answer answer = await Delete(sql, sqlParameters);
            return answer;
        }
    }
}