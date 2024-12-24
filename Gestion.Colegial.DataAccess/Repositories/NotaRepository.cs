using Gestion.Colegial.Entities;
using Gestion.Colegial.Entities.Entities.app;
using Gestion.Colegial.Entities.Entities.dbo;
using System.Data;
using System.Data.SqlClient;

namespace Gestion.Colegial.DataAccess.Repositories
{
    public class NotaRepository : RepositoryBase
    {
        public async Task<Answer> List()
        {
            const string sql = "PR_tbNotas_List";
            Answer answer = await Read<PR_tbNotas_ListResult>(sql);
            return answer;
        }

        public async Task<Answer> Find(int id)
        {
            const string sql = "PR_tbNotas_Find";
            SqlParameter[] sqlParameters = {
                new SqlParameter() { ParameterName = "@Not_Id", DbType = DbType.Int32, Value = id },
            };
            Answer answer = await Search<PR_tbNotas_FindResult>(sql, sqlParameters);
            return answer;
        }

        public async Task<Answer> Detail(int id)
        {
            const string sql = "PR_tbNotas_Detail";
            SqlParameter[] sqlParameters = {
                new SqlParameter() { ParameterName = "@Not_Id", DbType = DbType.Int32, Value = id },
            };
            Answer answer = await Details<PR_tbNotas_DetailResult>(sql, sqlParameters, id);
            return answer;
        }

        public async Task<Answer> Create(tbNotas obj)
        {
            obj.Not_UsuarioRegistra = 1;
            const string sql = "PR_tbNotas_Insert";
            SqlParameter[] sqlParameters = {
                new SqlParameter(){ParameterName= "@Not_Nota", DbType = DbType.Int32, Value = obj.Not_Nota},
                new SqlParameter(){ParameterName= "@Mat_Id", DbType = DbType.Int32, Value = obj.Mat_Id},
                new SqlParameter(){ParameterName= "@Sem_Id", DbType = DbType.Int32, Value = obj.Sem_Id},
                new SqlParameter(){ParameterName= "@Pac_Id", DbType = DbType.Int32, Value = obj.Pac_Id},
                new SqlParameter(){ParameterName= "@Not_Año", DbType = DbType.Date, Value = obj.Not_Año},
                new SqlParameter(){ParameterName= "@Not_UsuarioRegistra", DbType = DbType.Int32  , Value = obj.Not_UsuarioRegistra}
            };
            Answer answer = await New(sql, sqlParameters);
            return answer;
        }

        public async Task<Answer> Edit(tbNotas obj)
        {
            obj.Not_UsuarioModifica = 1;
            const string sql = "PR_tbNotas_Update";
            SqlParameter[] sqlParameters = {
                new SqlParameter(){ParameterName= "@Not_Id", DbType = DbType.Int32, Value = obj.Not_Id},
                new SqlParameter(){ParameterName= "@Not_Nota", DbType = DbType.Int32, Value = obj.Not_Nota},
                new SqlParameter(){ParameterName= "@Mat_Id", DbType = DbType.Int32, Value = obj.Mat_Id},
                new SqlParameter(){ParameterName= "@Sem_Id", DbType = DbType.Int32, Value = obj.Sem_Id},
                new SqlParameter(){ParameterName= "@Pac_Id", DbType = DbType.Int32, Value = obj.Pac_Id},
                new SqlParameter(){ParameterName= "@Not_Año", DbType = DbType.Date, Value = obj.Not_Año},
                new SqlParameter(){ParameterName= "@Not_EsActivo", DbType = DbType.String, Value = obj.Not_EsActivo},
                new SqlParameter(){ParameterName= "@Not_UsuarioModifica", DbType = DbType.Int32, Value = obj.Not_UsuarioModifica}
            };
            Answer answer = await Update(sql, sqlParameters);
            return answer;
        }

        //public async Task<IEnumerable<PR_tbNotas_ExistResult>> Exist(string value)
        //{
        //    const string sql = "PR_tbNotas_Exist";
        //    await db.SaveChangesAsync();
        //    if (resultado == null)
        //    {
        //        return null;
        //    }
        //    return resultado;
        //}

        public async Task<Answer> Delete(int id)
        {
            const string sql = "PR_tbNotas_Delete";
            SqlParameter[] sqlParameters = {
                new SqlParameter() { ParameterName = "@Not_Id", DbType = DbType.Int32, Value = id },
            };
            Answer answer = await Delete(sql, sqlParameters);
            return answer;
        }
    }
}
