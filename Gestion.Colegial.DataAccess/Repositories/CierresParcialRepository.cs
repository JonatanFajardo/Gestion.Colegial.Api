using Gestion.Colegial.DataAccess.Interfaces;
using Gestion.Colegial.Entities;
using Gestion.Colegial.Entities.DTOs;
using Gestion.Colegial.Entities.Entities;
using System.Data;
using System.Data.SqlClient;

namespace Gestion.Colegial.DataAccess.Repositories
{
    /// <summary>
    /// Cierre y publicación de parciales (script 075). Las escrituras devuelven una fila, por eso usan
    /// Search; si el procedimiento lanza un error de validación (THROW 50070-50079), Search lo deja en
    /// Answer (Incidents) y no lo relanza.
    /// </summary>
    public class CierresParcialRepository : RepositoryBase, ICierresParcialRepository
    {
        private static SqlParameter Entero(string nombre, int? valor) =>
            new SqlParameter() { ParameterName = nombre, DbType = DbType.Int32, Value = (object?)valor ?? DBNull.Value };

        private static SqlParameter Booleano(string nombre, bool valor) =>
            new SqlParameter() { ParameterName = nombre, DbType = DbType.Boolean, Value = valor };

        private static SqlParameter Fecha(string nombre, DateTime? valor) =>
            new SqlParameter() { ParameterName = nombre, DbType = DbType.Date, Value = valor.HasValue ? valor.Value.Date : DBNull.Value };

        private static SqlParameter Texto(string nombre, string? valor) =>
            new SqlParameter() { ParameterName = nombre, DbType = DbType.String, Value = string.IsNullOrWhiteSpace(valor) ? DBNull.Value : valor.Trim() };

        private static List<SqlParameter> Periodo(CierreParcialAccionDTO obj) => new List<SqlParameter>
        {
            Entero("@Anio", obj.Anio),
            Entero("@Sem_Id", obj.Sem_Id),
            Entero("@Pac_Id", obj.Pac_Id)
        };

        private static SqlParameter[] ConEscritor(List<SqlParameter> p, CierreParcialAccionDTO obj)
        {
            p.Add(Entero("@Usuario", obj.Usuario));
            p.Add(Booleano("@PuedeCerrar", obj.PuedeCerrar));
            return p.ToArray();
        }

        private Task<Answer> Escribir(string sp, SqlParameter[] p) =>
            Search<PR_CierresParcial_EscrituraResult>(sp, p);

        public async Task<Answer> Anios() =>
            await Read<PR_CierresParcial_AniosResult>("app.PR_CierresParcial_Anios", new SqlParameter[] { });

        public async Task<Answer> Estado(int anio) =>
            await Read<PR_CierresParcial_EstadoResult>("app.PR_CierresParcial_Estado", new[] { Entero("@Anio", anio) });

        public async Task<Answer> Faltantes(int anio, int semId, int pacId) =>
            await Read<PR_CierresParcial_FaltantesResult>("app.PR_CierresParcial_Faltantes",
                new[] { Entero("@Anio", anio), Entero("@Sem_Id", semId), Entero("@Pac_Id", pacId) });

        public async Task<Answer> Historial(int anio) =>
            await Read<PR_CierresParcial_HistorialResult>("app.PR_CierresParcial_Historial", new[] { Entero("@Anio", anio) });

        public async Task<Answer> Periodos(int? anio, int? semId, int? pacId, int? notId) =>
            await Read<PR_CierresParcial_PeriodosResult>("app.PR_CierresParcial_Periodos",
                new[] { Entero("@Anio", anio), Entero("@Sem_Id", semId), Entero("@Pac_Id", pacId), Entero("@Not_Id", notId) });

        public Task<Answer> Cerrar(CierreParcialAccionDTO obj)
        {
            var p = Periodo(obj);
            p.Add(Texto("@Motivo", obj.Motivo));
            p.Add(Booleano("@ConfirmarFaltantes", obj.ConfirmarFaltantes));
            return Escribir("app.PR_CierresParcial_Cerrar", ConEscritor(p, obj));
        }

        public Task<Answer> Publicar(CierreParcialAccionDTO obj) =>
            Escribir("app.PR_CierresParcial_Publicar", ConEscritor(Periodo(obj), obj));

        public Task<Answer> Despublicar(CierreParcialAccionDTO obj)
        {
            var p = Periodo(obj);
            p.Add(Texto("@Motivo", obj.Motivo));
            return Escribir("app.PR_CierresParcial_Despublicar", ConEscritor(p, obj));
        }

        public Task<Answer> Reabrir(CierreParcialAccionDTO obj)
        {
            var p = Periodo(obj);
            p.Add(Texto("@Motivo", obj.Motivo));
            return Escribir("app.PR_CierresParcial_Reabrir", ConEscritor(p, obj));
        }

        public Task<Answer> Fechas(CierreParcialAccionDTO obj)
        {
            var p = Periodo(obj);
            p.Add(Fecha("@FechaInicio", obj.FechaInicio));
            p.Add(Fecha("@FechaLimite", obj.FechaLimite));
            return Escribir("app.PR_CierresParcial_Fechas", ConEscritor(p, obj));
        }
    }
}
