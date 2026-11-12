using Gestion.Colegial.DataAccess.Interfaces;
using Gestion.Colegial.Entities;
using Gestion.Colegial.Entities.Entities;
using System.Data;
using System.Data.SqlClient;

namespace Gestion.Colegial.DataAccess.Repositories
{
    public class PeriodoAnioRepository : RepositoryBase, IPeriodoAnioRepository
    {
        public async Task<Answer> List(int anioId)
        {
            const string sql = "app.PR_tbPeriodosAnio_List";
            SqlParameter[] sqlParameters = {
                new SqlParameter(){ParameterName= "@value", DbType = DbType.Int32, Value = anioId },
            };
            Answer answer = await Read<PR_tbPeriodosAnio_ListResult>(sql, sqlParameters);
            return answer;
        }

        public async Task<Answer> Find(int id)
        {
            const string sql = "app.PR_tbPeriodosAnio_Find";
            SqlParameter[] sqlParameters = {
                new SqlParameter(){ParameterName= "@value", DbType = DbType.Int32, Value = id },
            };
            Answer answer = await Search<PR_tbPeriodosAnio_FindResult>(sql, sqlParameters);
            return answer;
        }

        public async Task<Answer> Create(tbPeriodosAnio obj)
        {
            obj.Pan_UsuarioRegistra = 1;
            const string sql = "app.PR_tbPeriodosAnio_Insert";
            SqlParameter[] sqlParameters = {
                new SqlParameter(){ParameterName= "@Ani_Id", DbType = DbType.Int32, Value = obj.Ani_Id },
                new SqlParameter(){ParameterName= "@Pan_Nombre", DbType = DbType.String, Value = (object)obj.Pan_Nombre ?? DBNull.Value },
                new SqlParameter(){ParameterName= "@Pan_Tipo", DbType = DbType.String, Value = string.IsNullOrWhiteSpace(obj.Pan_Tipo) ? "parcial" : obj.Pan_Tipo },
                new SqlParameter(){ParameterName= "@Pan_Orden", DbType = DbType.Int16, Value = obj.Pan_Orden == 0 ? (short)1 : obj.Pan_Orden },
                new SqlParameter(){ParameterName= "@Pan_FechaInicio", DbType = DbType.Date, Value = (object)obj.Pan_FechaInicio ?? DBNull.Value },
                new SqlParameter(){ParameterName= "@Pan_FechaFin", DbType = DbType.Date, Value = (object)obj.Pan_FechaFin ?? DBNull.Value },
                new SqlParameter(){ParameterName= "@Pan_Estado", DbType = DbType.Byte, Value = obj.Pan_Estado == 0 ? (byte)1 : obj.Pan_Estado },
                new SqlParameter(){ParameterName= "@Pan_UsuarioRegistra", DbType = DbType.Int32, Value = obj.Pan_UsuarioRegistra }
            };
            Answer answer = await NewWithId<PR_tbPeriodosAnio_InsertResult>(sql, sqlParameters);
            return answer;
        }

        public async Task<Answer> Edit(tbPeriodosAnio obj)
        {
            obj.Pan_UsuarioModifica = 1;
            const string sql = "app.PR_tbPeriodosAnio_Update";
            SqlParameter[] sqlParameters = {
                new SqlParameter(){ParameterName= "@Pan_Id", DbType = DbType.Int32, Value = obj.Pan_Id },
                new SqlParameter(){ParameterName= "@Ani_Id", DbType = DbType.Int32, Value = obj.Ani_Id },
                new SqlParameter(){ParameterName= "@Pan_Nombre", DbType = DbType.String, Value = (object)obj.Pan_Nombre ?? DBNull.Value },
                new SqlParameter(){ParameterName= "@Pan_Tipo", DbType = DbType.String, Value = string.IsNullOrWhiteSpace(obj.Pan_Tipo) ? "parcial" : obj.Pan_Tipo },
                new SqlParameter(){ParameterName= "@Pan_Orden", DbType = DbType.Int16, Value = obj.Pan_Orden == 0 ? (short)1 : obj.Pan_Orden },
                new SqlParameter(){ParameterName= "@Pan_FechaInicio", DbType = DbType.Date, Value = (object)obj.Pan_FechaInicio ?? DBNull.Value },
                new SqlParameter(){ParameterName= "@Pan_FechaFin", DbType = DbType.Date, Value = (object)obj.Pan_FechaFin ?? DBNull.Value },
                new SqlParameter(){ParameterName= "@Pan_Estado", DbType = DbType.Byte, Value = obj.Pan_Estado == 0 ? (byte)1 : obj.Pan_Estado },
                new SqlParameter(){ParameterName= "@Pan_UsuarioModifica", DbType = DbType.Int32, Value = obj.Pan_UsuarioModifica }
            };
            Answer answer = await Update(sql, sqlParameters);
            return answer;
        }

        public async Task<Answer> Delete(int id)
        {
            const string sql = "app.PR_tbPeriodosAnio_Delete";
            SqlParameter[] sqlParameters = {
                new SqlParameter(){ParameterName= "@value", DbType = DbType.Int32, Value = id }
            };
            Answer answer = await Delete(sql, sqlParameters);
            return answer;
        }
    }
}
