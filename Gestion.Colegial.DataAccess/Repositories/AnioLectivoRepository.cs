using Gestion.Colegial.DataAccess.Interfaces;
using Gestion.Colegial.Entities;
using Gestion.Colegial.Entities.Entities;
using System.Data;
using System.Data.SqlClient;

namespace Gestion.Colegial.DataAccess.Repositories
{
    public class AnioLectivoRepository : RepositoryBase, IAnioLectivoRepository
    {
        public async Task<Answer> List()
        {
            const string sql = "app.PR_tbAnioLectivo_List";
            SqlParameter[] sqlParameters = { };
            Answer answer = await Read<PR_tbAnioLectivo_ListResult>(sql, sqlParameters);
            return answer;
        }

        public async Task<Answer> Find(int id)
        {
            const string sql = "app.PR_tbAnioLectivo_Find";
            SqlParameter[] sqlParameters = {
                new SqlParameter(){ParameterName= "@Ani_Id", DbType = DbType.Int32, Value = id },
            };
            Answer answer = await Search<PR_tbAnioLectivo_FindResult>(sql, sqlParameters);
            return answer;
        }

        public async Task<Answer> Create(tbAnioLectivo obj)
        {
            obj.Ani_UsuarioRegistra = 1;
            const string sql = "app.PR_tbAnioLectivo_Insert";
            SqlParameter[] sqlParameters = {
                new SqlParameter(){ParameterName= "@Ani_Anio", DbType = DbType.Int32, Value = obj.Ani_Anio },
                new SqlParameter(){ParameterName= "@Ani_Nombre", DbType = DbType.String, Value = (object)obj.Ani_Nombre ?? DBNull.Value },
                new SqlParameter(){ParameterName= "@Ani_FechaInicio", DbType = DbType.Date, Value = (object)obj.Ani_FechaInicio ?? DBNull.Value },
                new SqlParameter(){ParameterName= "@Ani_FechaFin", DbType = DbType.Date, Value = (object)obj.Ani_FechaFin ?? DBNull.Value },
                new SqlParameter(){ParameterName= "@Ani_Estado", DbType = DbType.Byte, Value = obj.Ani_Estado == 0 ? (byte)1 : obj.Ani_Estado },
                new SqlParameter(){ParameterName= "@Ani_UsuarioRegistra", DbType = DbType.Int32, Value = obj.Ani_UsuarioRegistra }
            };
            Answer answer = await NewWithId<PR_tbAnioLectivo_InsertResult>(sql, sqlParameters);
            return answer;
        }

        public async Task<Answer> Edit(tbAnioLectivo obj)
        {
            obj.Ani_UsuarioModifica = 1;
            const string sql = "app.PR_tbAnioLectivo_Update";
            SqlParameter[] sqlParameters = {
                new SqlParameter(){ParameterName= "@Ani_Id", DbType = DbType.Int32, Value = obj.Ani_Id },
                new SqlParameter(){ParameterName= "@Ani_Anio", DbType = DbType.Int32, Value = obj.Ani_Anio },
                new SqlParameter(){ParameterName= "@Ani_Nombre", DbType = DbType.String, Value = (object)obj.Ani_Nombre ?? DBNull.Value },
                new SqlParameter(){ParameterName= "@Ani_FechaInicio", DbType = DbType.Date, Value = (object)obj.Ani_FechaInicio ?? DBNull.Value },
                new SqlParameter(){ParameterName= "@Ani_FechaFin", DbType = DbType.Date, Value = (object)obj.Ani_FechaFin ?? DBNull.Value },
                new SqlParameter(){ParameterName= "@Ani_Estado", DbType = DbType.Byte, Value = obj.Ani_Estado == 0 ? (byte)1 : obj.Ani_Estado },
                new SqlParameter(){ParameterName= "@Ani_UsuarioModifica", DbType = DbType.Int32, Value = obj.Ani_UsuarioModifica }
            };
            Answer answer = await Update(sql, sqlParameters);
            return answer;
        }

        public async Task<Answer> Delete(int id)
        {
            const string sql = "app.PR_tbAnioLectivo_Delete";
            SqlParameter[] sqlParameters = {
                new SqlParameter(){ParameterName= "@Ani_Id", DbType = DbType.Int32, Value = id }
            };
            Answer answer = await Delete(sql, sqlParameters);
            return answer;
        }

        public async Task<Answer> Exist(string value)
        {
            const string sql = "app.PR_tbAnioLectivo_Exist";
            SqlParameter[] sqlParameters = {
                new SqlParameter(){ParameterName= "@value", DbType = DbType.String, Value = (object)value ?? DBNull.Value },
            };
            Answer answer = await Search<PR_tbAnioLectivo_FindResult>(sql, sqlParameters);
            return answer;
        }

        public async Task<Answer> SetActivo(int id)
        {
            const string sql = "app.PR_tbAnioLectivo_SetActivo";
            SqlParameter[] sqlParameters = {
                new SqlParameter(){ParameterName= "@Ani_Id", DbType = DbType.Int32, Value = id }
            };
            Answer answer = await Update(sql, sqlParameters);
            return answer;
        }

        public async Task<Answer> Activo()
        {
            const string sql = "app.PR_tbAnioLectivo_Activo";
            SqlParameter[] sqlParameters = { };
            Answer answer = await Search<PR_tbAnioLectivo_FindResult>(sql, sqlParameters);
            return answer;
        }
    }
}
