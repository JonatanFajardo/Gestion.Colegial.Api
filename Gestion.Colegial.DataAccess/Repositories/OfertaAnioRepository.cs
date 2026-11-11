using Gestion.Colegial.DataAccess.Interfaces;
using Gestion.Colegial.Entities;
using Gestion.Colegial.Entities.Entities;
using System.Data;
using System.Data.SqlClient;

namespace Gestion.Colegial.DataAccess.Repositories
{
    /// <summary>
    /// Acceso a datos de las ofertas de asignatura por año (Fase 5).
    /// Clona el patrón de AnioLectivoRepository.
    /// </summary>
    public class OfertaAnioRepository : RepositoryBase, IOfertaAnioRepository
    {
        public async Task<Answer> List(int aniId)
        {
            const string sql = "app.PR_tbOfertasAnio_List";
            SqlParameter[] sqlParameters = {
                new SqlParameter(){ParameterName= "@Ani_Id", DbType = DbType.Int32, Value = aniId },
            };
            Answer answer = await Read<PR_tbOfertasAnio_ListResult>(sql, sqlParameters);
            return answer;
        }

        public async Task<Answer> Find(int id)
        {
            const string sql = "app.PR_tbOfertasAnio_Find";
            SqlParameter[] sqlParameters = {
                new SqlParameter(){ParameterName= "@value", DbType = DbType.Int32, Value = id },
            };
            Answer answer = await Search<PR_tbOfertasAnio_FindResult>(sql, sqlParameters);
            return answer;
        }

        public async Task<Answer> Create(tbOfertasAnio obj)
        {
            obj.Ofa_UsuarioRegistra = 1;
            const string sql = "app.PR_tbOfertasAnio_Insert";
            SqlParameter[] sqlParameters = {
                new SqlParameter(){ParameterName= "@Ani_Id", DbType = DbType.Int32, Value = obj.Ani_Id },
                new SqlParameter(){ParameterName= "@Mat_Id", DbType = DbType.Int32, Value = obj.Mat_Id },
                new SqlParameter(){ParameterName= "@Cun_Id", DbType = DbType.Int32, Value = (object)obj.Cun_Id ?? DBNull.Value },
                new SqlParameter(){ParameterName= "@Sea_Id", DbType = DbType.Int32, Value = (object)obj.Sea_Id ?? DBNull.Value },
                new SqlParameter(){ParameterName= "@Emp_Id", DbType = DbType.Int32, Value = (object)obj.Emp_Id ?? DBNull.Value },
                new SqlParameter(){ParameterName= "@Pan_Id", DbType = DbType.Int32, Value = (object)obj.Pan_Id ?? DBNull.Value },
                new SqlParameter(){ParameterName= "@Ofa_HorasSemana", DbType = DbType.Int32, Value = (object)obj.Ofa_HorasSemana ?? DBNull.Value },
                new SqlParameter(){ParameterName= "@Ofa_Estado", DbType = DbType.Byte, Value = obj.Ofa_Estado == 0 ? (byte)1 : obj.Ofa_Estado },
                new SqlParameter(){ParameterName= "@Ofa_UsuarioRegistra", DbType = DbType.Int32, Value = (object)obj.Ofa_UsuarioRegistra ?? DBNull.Value }
            };
            Answer answer = await NewWithId<PR_tbOfertasAnio_InsertResult>(sql, sqlParameters);
            return answer;
        }

        public async Task<Answer> Edit(tbOfertasAnio obj)
        {
            obj.Ofa_UsuarioModifica = 1;
            const string sql = "app.PR_tbOfertasAnio_Update";
            SqlParameter[] sqlParameters = {
                new SqlParameter(){ParameterName= "@Ofa_Id", DbType = DbType.Int32, Value = obj.Ofa_Id },
                new SqlParameter(){ParameterName= "@Ani_Id", DbType = DbType.Int32, Value = obj.Ani_Id },
                new SqlParameter(){ParameterName= "@Mat_Id", DbType = DbType.Int32, Value = obj.Mat_Id },
                new SqlParameter(){ParameterName= "@Cun_Id", DbType = DbType.Int32, Value = (object)obj.Cun_Id ?? DBNull.Value },
                new SqlParameter(){ParameterName= "@Sea_Id", DbType = DbType.Int32, Value = (object)obj.Sea_Id ?? DBNull.Value },
                new SqlParameter(){ParameterName= "@Emp_Id", DbType = DbType.Int32, Value = (object)obj.Emp_Id ?? DBNull.Value },
                new SqlParameter(){ParameterName= "@Pan_Id", DbType = DbType.Int32, Value = (object)obj.Pan_Id ?? DBNull.Value },
                new SqlParameter(){ParameterName= "@Ofa_HorasSemana", DbType = DbType.Int32, Value = (object)obj.Ofa_HorasSemana ?? DBNull.Value },
                new SqlParameter(){ParameterName= "@Ofa_Estado", DbType = DbType.Byte, Value = obj.Ofa_Estado == 0 ? (byte)1 : obj.Ofa_Estado },
                new SqlParameter(){ParameterName= "@Ofa_UsuarioModifica", DbType = DbType.Int32, Value = (object)obj.Ofa_UsuarioModifica ?? DBNull.Value }
            };
            Answer answer = await Update(sql, sqlParameters);
            return answer;
        }

        public async Task<Answer> Delete(int id)
        {
            const string sql = "app.PR_tbOfertasAnio_Delete";
            SqlParameter[] sqlParameters = {
                new SqlParameter(){ParameterName= "@value", DbType = DbType.Int32, Value = id }
            };
            Answer answer = await Delete(sql, sqlParameters);
            return answer;
        }
    }
}
