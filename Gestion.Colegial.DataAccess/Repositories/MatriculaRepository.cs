using Gestion.Colegial.DataAccess.Interfaces;
using Gestion.Colegial.Entities;
using Gestion.Colegial.Entities.Entities;
using System.Data;
using System.Data.SqlClient;

namespace Gestion.Colegial.DataAccess.Repositories
{
    public class MatriculaRepository : RepositoryBase, IMatriculaRepository
    {
        public async Task<Answer> List(int anio)
        {
            const string sql = "app.PR_tbMatriculas_List";
            SqlParameter[] sqlParameters = {
                new SqlParameter(){ParameterName= "@Anio", DbType = DbType.Int32, Value = anio },
            };
            Answer answer = await Read<PR_tbMatriculas_ListResult>(sql, sqlParameters);
            return answer;
        }

        public async Task<Answer> Find(int id)
        {
            const string sql = "app.PR_tbMatriculas_Find";
            SqlParameter[] sqlParameters = {
                new SqlParameter(){ParameterName= "@Matri_Id", DbType = DbType.Int32, Value = id },
            };
            Answer answer = await Search<PR_tbMatriculas_FindResult>(sql, sqlParameters);
            return answer;
        }

        public async Task<Answer> Create(tbMatriculas obj)
        {
            obj.Matri_UsuarioRegistra = 1;
            const string sql = "app.PR_tbMatriculas_Insert";
            SqlParameter[] sqlParameters = {
                new SqlParameter(){ParameterName= "@Alu_Id", DbType = DbType.Int32, Value = obj.Alu_Id },
                new SqlParameter(){ParameterName= "@Matri_Anio", DbType = DbType.Int32, Value = obj.Matri_Anio },
                new SqlParameter(){ParameterName= "@Cun_Id", DbType = DbType.Int32, Value = (object)obj.Cun_Id ?? DBNull.Value },
                new SqlParameter(){ParameterName= "@Sec_Id", DbType = DbType.Int32, Value = (object)obj.Sec_Id ?? DBNull.Value },
                new SqlParameter(){ParameterName= "@Matri_FechaInicio", DbType = DbType.Date, Value = obj.Matri_FechaInicio },
                new SqlParameter(){ParameterName= "@Matri_FechaFin", DbType = DbType.Date, Value = (object)obj.Matri_FechaFin ?? DBNull.Value },
                new SqlParameter(){ParameterName= "@Est_Id", DbType = DbType.Int32, Value = (object)obj.Est_Id ?? DBNull.Value },
                new SqlParameter(){ParameterName= "@Matri_UsuarioRegistra", DbType = DbType.Int32, Value = obj.Matri_UsuarioRegistra }
            };
            Answer answer = await NewWithId<PR_tbMatriculas_InsertResult>(sql, sqlParameters);
            return answer;
        }

        public async Task<Answer> Edit(tbMatriculas obj)
        {
            obj.Matri_UsuarioModifica = 1;
            const string sql = "app.PR_tbMatriculas_Update";
            SqlParameter[] sqlParameters = {
                new SqlParameter(){ParameterName= "@Matri_Id", DbType = DbType.Int32, Value = obj.Matri_Id },
                new SqlParameter(){ParameterName= "@Alu_Id", DbType = DbType.Int32, Value = obj.Alu_Id },
                new SqlParameter(){ParameterName= "@Matri_Anio", DbType = DbType.Int32, Value = obj.Matri_Anio },
                new SqlParameter(){ParameterName= "@Cun_Id", DbType = DbType.Int32, Value = (object)obj.Cun_Id ?? DBNull.Value },
                new SqlParameter(){ParameterName= "@Sec_Id", DbType = DbType.Int32, Value = (object)obj.Sec_Id ?? DBNull.Value },
                new SqlParameter(){ParameterName= "@Matri_FechaInicio", DbType = DbType.Date, Value = obj.Matri_FechaInicio },
                new SqlParameter(){ParameterName= "@Matri_FechaFin", DbType = DbType.Date, Value = (object)obj.Matri_FechaFin ?? DBNull.Value },
                new SqlParameter(){ParameterName= "@Est_Id", DbType = DbType.Int32, Value = (object)obj.Est_Id ?? DBNull.Value },
                new SqlParameter(){ParameterName= "@Matri_UsuarioModifica", DbType = DbType.Int32, Value = obj.Matri_UsuarioModifica }
            };
            Answer answer = await Update(sql, sqlParameters);
            return answer;
        }

        public async Task<Answer> Delete(int id)
        {
            const string sql = "app.PR_tbMatriculas_Delete";
            SqlParameter[] sqlParameters = {
                new SqlParameter(){ParameterName= "@Matri_Id", DbType = DbType.Int32, Value = id }
            };
            Answer answer = await Delete(sql, sqlParameters);
            return answer;
        }
    }
}
