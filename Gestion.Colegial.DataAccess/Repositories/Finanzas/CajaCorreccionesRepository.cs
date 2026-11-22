using Gestion.Colegial.DataAccess.Interfaces.Finanzas;
using Gestion.Colegial.Entities;
using Gestion.Colegial.Entities.DTOs.finansas;
using Gestion.Colegial.Entities.Entities;
using System.Data;
using System.Data.SqlClient;

namespace Gestion.Colegial.DataAccess.Repositories.Finanzas
{
    /// <summary>
    /// Correcciones de caja: anular pagos, perdonar cargos y saldo a favor (script 068).
    /// Los procedimientos validan y lanzan THROW 500xx con el mensaje para el usuario.
    /// </summary>
    public class CajaCorreccionesRepository : RepositoryBase, ICajaCorreccionesRepository
    {
        private static SqlParameter Entero(string nombre, int? valor) =>
            new SqlParameter() { ParameterName = nombre, DbType = DbType.Int32, Value = (object?)valor ?? DBNull.Value };

        private static SqlParameter Dinero(string nombre, decimal valor) =>
            new SqlParameter() { ParameterName = nombre, SqlDbType = SqlDbType.Decimal, Precision = 18, Scale = 2, Value = valor };

        private static SqlParameter Texto(string nombre, string? valor) =>
            new SqlParameter() { ParameterName = nombre, DbType = DbType.String, Value = string.IsNullOrWhiteSpace(valor) ? DBNull.Value : valor.Trim() };

        public async Task<Answer> AnularPago(PagoAnularDto obj)
        {
            SqlParameter[] p =
            {
                Entero("@Pag_Id", obj.PagoId), Texto("@Motivo", obj.Motivo),
                Texto("@Destino", obj.Destino), Entero("@Usu_Id", obj.UsuarioId)
            };
            return await Search<PR_tbPagos_AnularResult>("finanza.PR_tbPagos_Anular", p);
        }

        public async Task<Answer> PerdonarCargo(CuentaCobrarPerdonarDto obj)
        {
            SqlParameter[] p =
            {
                Entero("@Cco_Id", obj.CuentaCobrarId), Dinero("@Monto", obj.Monto), Texto("@Tipo", obj.Tipo),
                Texto("@Motivo", obj.Motivo), Entero("@Usu_Id", obj.UsuarioId)
            };
            return await Search<PR_tbCuentasCobrar_PerdonarResult>("finanza.PR_tbCuentasCobrar_Perdonar", p);
        }

        public async Task<Answer> ObtenerSaldoFavor(int alumnoId)
        {
            SqlParameter[] p = { Entero("@Alu_Id", alumnoId) };
            return await Search<PR_SaldoFavorResult>("finanza.PR_SaldoFavor_Obtener", p);
        }

        public async Task<Answer> DevolverSaldoFavor(SaldoFavorDevolverDto obj)
        {
            SqlParameter[] p =
            {
                Entero("@Alu_Id", obj.AlumnoId), Dinero("@Monto", obj.Monto), Texto("@Metodo", obj.Metodo),
                Texto("@Motivo", obj.Motivo), Entero("@Usu_Id", obj.UsuarioId)
            };
            return await Search<PR_SaldoFavorResult>("finanza.PR_SaldoFavor_Devolver", p);
        }

        public async Task<Answer> AplicarSaldoFavor(SaldoFavorAplicarDto obj)
        {
            SqlParameter[] p =
            {
                Entero("@Alu_Id", obj.AlumnoId), Dinero("@Monto", obj.Monto),
                Texto("@Motivo", obj.Motivo), Entero("@Usu_Id", obj.UsuarioId)
            };
            return await Search<PR_SaldoFavor_AplicarResult>("finanza.PR_SaldoFavor_Aplicar", p);
        }

        public async Task<Answer> CorreccionesPorAlumno(int alumnoId)
        {
            SqlParameter[] p = { Entero("@Alu_Id", alumnoId) };
            return await Read<PR_Correcciones_ListByAlumnoResult>("finanza.PR_Correcciones_ListByAlumno", p);
        }
    }
}
