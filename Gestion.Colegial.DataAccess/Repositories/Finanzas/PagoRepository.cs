using Gestion.Colegial.DataAccess.Interfaces.Finanzas;
using Gestion.Colegial.Entities;
using Gestion.Colegial.Entities.DTOs.finansas;
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
            Answer answer = await Read<PR_tbPagos_ListResult>(sql, sqlParameters);
            return answer;
        }

        public async Task<Answer> ListByFecha(DateTime fecha)
        {
            const string sql = "finanza.PR_tbPagos_ListByFecha";
            SqlParameter[] sqlParameters = {
                new SqlParameter(){ParameterName= "@Fecha", DbType = DbType.DateTime, Value = fecha },
            };
            Answer answer = await Read<PR_tbPagos_ListResult>(sql, sqlParameters);
            return answer;
        }

        public async Task<Answer> ListByRangoFechas(DateTime fechaInicio, DateTime fechaFin)
        {
            const string sql = "finanza.PR_tbPagos_ListByRangoFechas";
            SqlParameter[] sqlParameters = {
                new SqlParameter(){ParameterName= "@FechaInicio", DbType = DbType.DateTime, Value = fechaInicio },
                new SqlParameter(){ParameterName= "@FechaFin", DbType = DbType.DateTime, Value = fechaFin },
            };
            Answer answer = await Read<PR_tbPagos_ListResult>(sql, sqlParameters);
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
            Answer answer = await NewWithId<PR_tbPagos_InsertResult>(sql, sqlParameters);
            return answer;
        }

        /// <summary>
        /// Registra el pago y, si trae cargos, lo aplica a ellos (del más viejo al más nuevo);
        /// el excedente entra al saldo a favor del alumno. Todo en una transacción (script 068).
        /// </summary>
        public async Task<Answer> Registrar(PagoFindDto dto)
        {
            const string sql = "finanza.PR_tbPagos_Registrar";
            string? cargos = dto.CuentasCobrarIds == null || dto.CuentasCobrarIds.Count == 0
                ? null
                : string.Join(",", dto.CuentasCobrarIds);
            SqlParameter[] sqlParameters = {
                new SqlParameter(){ParameterName= "@Alu_Id", DbType = DbType.Int32, Value = dto.AlumnoId },
                new SqlParameter(){ParameterName= "@Enc_Id", DbType = DbType.Int32, Value = (object?)dto.EncargadoId ?? DBNull.Value },
                new SqlParameter(){ParameterName= "@Fpa_Id", DbType = DbType.Int32, Value = dto.FormaPagoId },
                new SqlParameter(){ParameterName= "@Pag_MontoTotal", SqlDbType = SqlDbType.Decimal, Precision = 18, Scale = 2, Value = dto.MontoTotal },
                new SqlParameter(){ParameterName= "@Pag_FechaPago", DbType = DbType.DateTime2, Value = dto.FechaPago == default ? DBNull.Value : dto.FechaPago },
                new SqlParameter(){ParameterName= "@Pag_NumeroReferencia", DbType = DbType.String, Value = string.IsNullOrWhiteSpace(dto.NumeroReferencia) ? DBNull.Value : dto.NumeroReferencia.Trim() },
                new SqlParameter(){ParameterName= "@Pag_Observaciones", DbType = DbType.String, Value = string.IsNullOrWhiteSpace(dto.Observaciones) ? DBNull.Value : dto.Observaciones.Trim() },
                new SqlParameter(){ParameterName= "@Usu_Id", DbType = DbType.Int32, Value = dto.UsuarioId },
                new SqlParameter(){ParameterName= "@Cargos", DbType = DbType.String, Value = (object?)cargos ?? DBNull.Value },
            };
            return await Search<PR_tbPagos_RegistrarResult>(sql, sqlParameters);
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
