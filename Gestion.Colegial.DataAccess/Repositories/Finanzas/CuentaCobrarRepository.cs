using Gestion.Colegial.DataAccess.Interfaces;
using Gestion.Colegial.Entities;
using Gestion.Colegial.Entities.Entities;
using System.Data;
using System.Data.SqlClient;

namespace Gestion.Colegial.DataAccess.Repositories.Finanzas
{
    public class CuentaCobrarRepository : RepositoryBase, ICuentaCobrarRepository
    {
        public async Task<Answer> List()
        {
            const string sql = "finanza.PR_tbCuentasCobrar_List";
            Answer answer = await Read<PR_tbCuentasCobrar_ListResult>(sql);
            return answer;
        }

        public async Task<Answer> ListByAlumno(int alumnoId)
        {
            const string sql = "finanza.PR_tbCuentasCobrar_ListByAlumno";
            SqlParameter[] sqlParameters = {
                new SqlParameter(){ParameterName= "@Alu_Id", DbType = DbType.Int32, Value = alumnoId },
            };
            Answer answer = await Read<PR_tbCuentasCobrar_ListByAlumnoResult>(sql, sqlParameters);
            return answer;
        }

        public async Task<Answer> ListPendientes()
        {
            const string sql = "finanza.PR_tbCuentasCobrar_ListPendientes";
            Answer answer = await Read<PR_tbCuentasCobrar_ListPendientesResult>(sql);
            return answer;
        }

        public async Task<Answer> ListVencidas()
        {
            const string sql = "finanza.PR_tbCuentasCobrar_ListVencidas";
            Answer answer = await Read<PR_tbCuentasCobrar_ListVencidasResult>(sql);
            return answer;
        }

        public async Task<Answer> Find(int id)
        {
            const string sql = "finanza.PR_tbCuentasCobrar_Find";
            SqlParameter[] sqlParameters = {
                new SqlParameter(){ParameterName= "@Cco_Id", DbType = DbType.Int32, Value = id },
            };
            Answer answer = await Search<PR_tbCuentasCobrar_FindResult>(sql, sqlParameters);
            return answer;
        }

        public async Task<Answer> Detail(int id)
        {
            const string sql = "finanza.PR_tbCuentasCobrar_Detail";
            SqlParameter[] sqlParameters = {
                new SqlParameter(){ParameterName= "@Cco_Id", DbType = DbType.Int32, Value = id },
            };
            Answer answer = await Details<PR_tbCuentasCobrar_DetailResult>(sql, sqlParameters, id);
            return answer;
        }

        public async Task<Answer> Create(tbCuentasCobrar obj)
        {
            const string sql = "finanza.PR_tbCuentasCobrar_Insert";
            SqlParameter[] sqlParameters = {
                new SqlParameter(){ParameterName= "@Alu_Id", DbType = DbType.Int32, Value = obj.Alu_Id },
                new SqlParameter(){ParameterName= "@Cpa_Id", DbType = DbType.Int32, Value = obj.Cpa_Id },
                new SqlParameter(){ParameterName= "@Tar_Id", DbType = DbType.Int32, Value = obj.Tar_Id },
                new SqlParameter(){ParameterName= "@Cco_MontoOriginal", DbType = DbType.Decimal, Value = obj.Cco_MontoOriginal },
                new SqlParameter(){ParameterName= "@Cco_FechaEmision", DbType = DbType.DateTime, Value = obj.Cco_FechaEmision },
                new SqlParameter(){ParameterName= "@Cco_FechaVencimiento", DbType = DbType.DateTime, Value = obj.Cco_FechaVencimiento },
            };
            Answer answer = await New(sql, sqlParameters);
            return answer;
        }

        public async Task<Answer> Edit(tbCuentasCobrar obj)
        {
            const string sql = "finanza.PR_tbCuentasCobrar_Update";
            SqlParameter[] sqlParameters = {
                new SqlParameter(){ParameterName= "@Cco_Id", DbType = DbType.Int32, Value = obj.Cco_Id },
                new SqlParameter(){ParameterName= "@Cco_MontoOriginal", DbType = DbType.Decimal, Value = obj.Cco_MontoOriginal },
                new SqlParameter(){ParameterName= "@Cco_MontoDescuento", DbType = DbType.Decimal, Value = obj.Cco_MontoDescuento },
                new SqlParameter(){ParameterName= "@Cco_MontoMora", DbType = DbType.Decimal, Value = obj.Cco_MontoMora },
                new SqlParameter(){ParameterName= "@Cco_FechaVencimiento", DbType = DbType.DateTime, Value = obj.Cco_FechaVencimiento },
                new SqlParameter(){ParameterName= "@Epa_Id", DbType = DbType.Int32, Value = obj.Epa_Id },
            };
            Answer answer = await Update(sql, sqlParameters);
            return answer;
        }

        public async Task<Answer> Delete(int id)
        {
            const string sql = "finanza.PR_tbCuentasCobrar_Delete";
            SqlParameter[] sqlParameters = {
                new SqlParameter(){ParameterName= "@Cco_Id", DbType = DbType.Int32, Value = id },
            };
            Answer answer = await Delete(sql, sqlParameters);
            return answer;
        }

        public async Task<Answer> GenerarCargosAlumno(int alumnoId, int anio)
        {
            const string sql = "finanza.PR_tbCuentasCobrar_GenerarCargosAlumno";
            SqlParameter[] sqlParameters = {
                new SqlParameter(){ParameterName= "@Alu_Id", DbType = DbType.Int32, Value = alumnoId },
                new SqlParameter(){ParameterName= "@Anio", DbType = DbType.Int32, Value = anio },
            };
            Answer answer = await New(sql, sqlParameters);
            return answer;
        }

        public async Task<Answer> AplicarDescuento(int cuentaCobrarId, int descuentoId, decimal monto, string justificacion)
        {
            const string sql = "finanza.PR_tbCuentasCobrar_AplicarDescuento";
            SqlParameter[] sqlParameters = {
                new SqlParameter(){ParameterName= "@Cco_Id", DbType = DbType.Int32, Value = cuentaCobrarId },
                new SqlParameter(){ParameterName= "@Des_Id", DbType = DbType.Int32, Value = descuentoId },
                new SqlParameter(){ParameterName= "@Dap_MontoAplicado", DbType = DbType.Decimal, Value = monto },
                new SqlParameter(){ParameterName= "@Dap_Justificacion", DbType = DbType.String, Value = justificacion },
            };
            Answer answer = await New(sql, sqlParameters);
            return answer;
        }

        public async Task<Answer> CalcularMoratoria(int cuentaCobrarId)
        {
            const string sql = "finanza.PR_tbCuentasCobrar_CalcularMoratoria";
            SqlParameter[] sqlParameters = {
                new SqlParameter(){ParameterName= "@Cco_Id", DbType = DbType.Int32, Value = cuentaCobrarId },
            };
            Answer answer = await New(sql, sqlParameters);
            return answer;
        }

        public async Task<Answer> ListDeudores()
        {
            const string sql = "finanza.PR_tbCuentasCobrar_ListDeudores";
            Answer answer = await Read<PR_tbCuentasCobrar_ListDeudoresResult>(sql);
            return answer;
        }

        public async Task<Answer> GenerarCargosMasivos(object filtros)
        {
            const string sql = "finanza.PR_tbCuentasCobrar_GenerarCargosMasivos";
            dynamic f = filtros;
            SqlParameter[] sqlParameters = {
                new SqlParameter(){ParameterName= "@Anio", DbType = DbType.Int32, Value = f.anio },
                new SqlParameter(){ParameterName= "@Niv_Id", DbType = DbType.Int32, Value = (object)f.nivelId ?? DBNull.Value },
                new SqlParameter(){ParameterName= "@Cun_Id", DbType = DbType.Int32, Value = (object)f.cursoId ?? DBNull.Value },
                new SqlParameter(){ParameterName= "@Sec_Id", DbType = DbType.Int32, Value = (object)f.seccionId ?? DBNull.Value },
                new SqlParameter(){ParameterName= "@ConceptosIds", DbType = DbType.String, Value = string.Join(",", f.conceptos) },
            };
            Answer answer = await New(sql, sqlParameters);
            return answer;
        }

        public async Task<Answer> PrevisualizarCargos(object filtros)
        {
            const string sql = "finanza.PR_tbCuentasCobrar_PrevisualizarCargos";
            dynamic f = filtros;
            SqlParameter[] sqlParameters = {
                new SqlParameter(){ParameterName= "@Anio", DbType = DbType.Int32, Value = f.anio },
                new SqlParameter(){ParameterName= "@Niv_Id", DbType = DbType.Int32, Value = (object)f.nivelId ?? DBNull.Value },
                new SqlParameter(){ParameterName= "@Cun_Id", DbType = DbType.Int32, Value = (object)f.cursoId ?? DBNull.Value },
                new SqlParameter(){ParameterName= "@Sec_Id", DbType = DbType.Int32, Value = (object)f.seccionId ?? DBNull.Value },
            };
            Answer answer = await Read<PR_tbCuentasCobrar_PrevisualizarCargosResult>(sql, sqlParameters);
            return answer;
        }

        public async Task<Answer> GenerarMensualidad(byte mes, short anio, int usuarioId, int? conceptoMensualidadId = null)
        {
            const string sql = "finanza.PR_GenerarMensualidad";
            SqlParameter[] sqlParameters = {
                new SqlParameter(){ParameterName= "@Mes", DbType = DbType.Byte, Value = mes },
                new SqlParameter(){ParameterName= "@Anio", DbType = DbType.Int16, Value = anio },
                new SqlParameter(){ParameterName= "@Usu_Id", DbType = DbType.Int32, Value = usuarioId },
                new SqlParameter(){ParameterName= "@ConceptoMensualidadId", DbType = DbType.Int32, Value = (object)conceptoMensualidadId ?? DBNull.Value },
            };
            Answer answer = await Read<PR_GenerarMensualidadResult>(sql, sqlParameters);
            return answer;
        }

        public async Task<Answer> GenerarMensualidadesRango(byte mesInicio, byte mesFin, short anio, int usuarioId)
        {
            const string sql = "finanza.PR_GenerarMensualidadesRango";
            SqlParameter[] sqlParameters = {
                new SqlParameter(){ParameterName= "@MesInicio", DbType = DbType.Byte, Value = mesInicio },
                new SqlParameter(){ParameterName= "@MesFin", DbType = DbType.Byte, Value = mesFin },
                new SqlParameter(){ParameterName= "@Anio", DbType = DbType.Int16, Value = anio },
                new SqlParameter(){ParameterName= "@Usu_Id", DbType = DbType.Int32, Value = usuarioId },
            };
            Answer answer = await Read<PR_GenerarMensualidadesRangoResult>(sql, sqlParameters);
            return answer;
        }

        public async Task<Answer> MesesPendientesPorAlumno(int alumnoId, short? anio = null)
        {
            const string sql = "finanza.PR_MesesPendientesPorAlumno";
            SqlParameter[] sqlParameters = {
                new SqlParameter(){ParameterName= "@Alu_Id", DbType = DbType.Int32, Value = alumnoId },
                new SqlParameter(){ParameterName= "@Anio", DbType = DbType.Int16, Value = (object)anio ?? DBNull.Value },
            };
            Answer answer = await Read<PR_MesesPendientesPorAlumnoResult>(sql, sqlParameters);
            return answer;
        }
    }
}
