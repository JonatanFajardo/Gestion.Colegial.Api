using Gestion.Colegial.DataAccess.Interfaces;
using Gestion.Colegial.Entities;
using Gestion.Colegial.Entities.Entities;
using System.Data;
using System.Data.SqlClient;

namespace Gestion.Colegial.DataAccess.Repositories.Finanzas
{
    public class PagoRepository : RepositoryBase, IPagoRepository
    {
        public async Task<Answer> List()
        {
            const string sql = "finanza.PR_tbPagos_List";
            Answer answer = await Read<PR_tbPagos_ListResult>(sql);
            return answer;
        }

        public async Task<Answer> ListByAlumno(int alumnoId)
        {
            const string sql = "finanza.PR_tbPagos_ListByAlumno";
            SqlParameter[] sqlParameters = {
                new SqlParameter(){ParameterName= "@Alu_Id", DbType = DbType.Int32, Value = alumnoId },
            };
            Answer answer = await Read<PR_tbPagos_ListByAlumnoResult>(sql, sqlParameters);
            return answer;
        }

        public async Task<Answer> ListByFecha(DateTime fecha)
        {
            const string sql = "finanza.PR_tbPagos_ListByFecha";
            SqlParameter[] sqlParameters = {
                new SqlParameter(){ParameterName= "@Fecha", DbType = DbType.DateTime, Value = fecha },
            };
            Answer answer = await Read<PR_tbPagos_ListByFechaResult>(sql, sqlParameters);
            return answer;
        }

        public async Task<Answer> ListByRangoFechas(DateTime fechaInicio, DateTime fechaFin)
        {
            const string sql = "finanza.PR_tbPagos_ListByRangoFechas";
            SqlParameter[] sqlParameters = {
                new SqlParameter(){ParameterName= "@FechaInicio", DbType = DbType.DateTime, Value = fechaInicio },
                new SqlParameter(){ParameterName= "@FechaFin", DbType = DbType.DateTime, Value = fechaFin },
            };
            Answer answer = await Read<PR_tbPagos_ListByRangoFechasResult>(sql, sqlParameters);
            return answer;
        }

        public async Task<Answer> Find(int id)
        {
            const string sql = "finanza.PR_tbPagos_Find";
            SqlParameter[] sqlParameters = {
                new SqlParameter(){ParameterName= "@Pag_Id", DbType = DbType.Int32, Value = id },
            };
            Answer answer = await Search<PR_tbPagos_FindResult>(sql, sqlParameters);
            return answer;
        }

        public async Task<Answer> Detail(int id)
        {
            const string sql = "finanza.PR_tbPagos_Detail";
            SqlParameter[] sqlParameters = {
                new SqlParameter(){ParameterName= "@Pag_Id", DbType = DbType.Int32, Value = id },
            };
            Answer answer = await Details<PR_tbPagos_DetailResult>(sql, sqlParameters, id);
            return answer;
        }

        public async Task<Answer> Create(tbPagos obj)
        {
            const string sql = "finanza.PR_tbPagos_Insert";
            SqlParameter[] sqlParameters = {
                new SqlParameter(){ParameterName= "@Alu_Id", DbType = DbType.Int32, Value = obj.Alu_Id },
                new SqlParameter(){ParameterName= "@Enc_Id", DbType = DbType.Int32, Value = (object)obj.Enc_Id ?? DBNull.Value },
                new SqlParameter(){ParameterName= "@Fpa_Id", DbType = DbType.Int32, Value = obj.Fpa_Id },
                new SqlParameter(){ParameterName= "@Pag_MontoTotal", DbType = DbType.Decimal, Value = obj.Pag_MontoTotal },
                new SqlParameter(){ParameterName= "@Pag_FechaPago", DbType = DbType.DateTime, Value = obj.Pag_FechaPago },
                new SqlParameter(){ParameterName= "@Pag_NumeroReferencia", DbType = DbType.String, Value = (object)obj.Pag_NumeroReferencia ?? DBNull.Value },
                new SqlParameter(){ParameterName= "@Pag_Observaciones", DbType = DbType.String, Value = (object)obj.Pag_Observaciones ?? DBNull.Value },
            };
            Answer answer = await New(sql, sqlParameters);
            return answer;
        }

        public async Task<Answer> Delete(int id)
        {
            const string sql = "finanza.PR_tbPagos_Delete";
            SqlParameter[] sqlParameters = {
                new SqlParameter(){ParameterName= "@Pag_Id", DbType = DbType.Int32, Value = id },
            };
            Answer answer = await Delete(sql, sqlParameters);
            return answer;
        }

        public async Task<Answer> GetRecibo(int pagoId)
        {
            const string sql = "finanza.PR_tbPagos_GetRecibo";
            SqlParameter[] sqlParameters = {
                new SqlParameter(){ParameterName= "@Pag_Id", DbType = DbType.Int32, Value = pagoId },
            };
            Answer answer = await Search<PR_tbPagos_GetReciboResult>(sql, sqlParameters);
            return answer;
        }
    }
}
