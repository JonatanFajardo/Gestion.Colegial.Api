using Gestion.Colegial.Entities;
using Gestion.Colegial.Entities.Entities.app;
using Gestion.Colegial.Entities.Entities.dbo;
using System.Data;
using System.Data.SqlClient;

namespace Gestion.Colegial.DataAccess.Repositories
{
    public class NivelEducativoRepository : RepositoryBase
    {
        public async Task<Answer> List()
        {
            const string sql = "PR_tbNivelesEducativos_List";
            Answer answer = await Read<PR_tbNivelesEducativos_ListResult>(sql);
            return answer;
        }

        public async Task<Answer> Find(int id)
        {
            const string sql = "PR_tbNivelesEducativos_Find";
            SqlParameter[] sqlParameters = {
                new SqlParameter() { ParameterName = "@Niv_Id", DbType = DbType.Int32, Value = id },
            };
            Answer answer = await Search<PR_tbNivelesEducativos_FindResult>(sql, sqlParameters);
            return answer;
        }

        public async Task<Answer> Detail(int id)
        {
            const string sql = "PR_tbNivelesEducativos_Detail";
            SqlParameter[] sqlParameters = {
                new SqlParameter() { ParameterName = "@Niv_Id", DbType = DbType.Int32, Value = id },
            };
            Answer answer = await Details<PR_tbNivelesEducativos_DetailResult>(sql, sqlParameters, id);
            return answer;
        }

        public async Task<Answer> Create(tbNivelesEducativos obj)
        {
            obj.Niv_UsuarioRegistra = 1;
            const string sql = "PR_tbNivelesEducativos_Insert";
            SqlParameter[] sqlParameters = {
                new SqlParameter(){ParameterName= "@Niv_Descripcion", DbType = DbType.String, Value = obj.Niv_Descripcion},
                new SqlParameter(){ParameterName= "@Niv_UsuarioRegistra", DbType = DbType.Int32  , Value = obj.Niv_UsuarioRegistra}
            };
            Answer answer = await New(sql, sqlParameters);
            return answer;
        }

        public async Task<Answer> Edit(tbNivelesEducativos obj)
        {
            obj.Niv_UsuarioModifica = 1;
            const string sql = "PR_tbNivelesEducativos_Update";
            SqlParameter[] sqlParameters = {
                new SqlParameter(){ParameterName= "@Niv_Id", DbType = DbType.Int32, Value = obj.Niv_Id},
                new SqlParameter(){ParameterName= "@Niv_Descripcion", DbType = DbType.String, Value = obj.Niv_Descripcion},
                new SqlParameter(){ParameterName= "@EsActivo", DbType = DbType.String, Value = obj.Niv_EsActivo},
                new SqlParameter(){ParameterName= "@Niv_UsuarioModifica", DbType = DbType.Int32, Value = obj.Niv_UsuarioModifica}
            };
            Answer answer = await Update(sql, sqlParameters);
            return answer;
        }

        public async Task<Answer> Exist(string value)
        {
            const string sql = "PR_tbNivelesEducativos_Exist";
            SqlParameter[] sqlParameters = {
                new SqlParameter(){ParameterName= "@Niv_Descripcion", DbType = DbType.String, Value = value}
            };
            Answer answer = await Exist<PR_tbNivelesEducativos_ExistResult>(sql, sqlParameters);
            return answer;
        }

        public async Task<Answer> Delete(int id)
        {
            const string sql = "PR_tbNivelesEducativos_Delete";
            SqlParameter[] sqlParameters = {
                new SqlParameter() { ParameterName = "@Niv_Id", DbType = DbType.Int32, Value = id },
            };
            Answer answer = await Delete(sql, sqlParameters);
            return answer;
        }
    }
}