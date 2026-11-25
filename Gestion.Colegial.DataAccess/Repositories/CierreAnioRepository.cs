using Gestion.Colegial.DataAccess.Interfaces;
using Gestion.Colegial.Entities;
using Gestion.Colegial.Entities.DTOs;
using Gestion.Colegial.Entities.Entities;
using System.Data;
using System.Data.SqlClient;

namespace Gestion.Colegial.DataAccess.Repositories
{
    /// <summary>
    /// Cierre del año escolar (script 090). Las escrituras devuelven una fila, por eso usan Search; si el
    /// procedimiento lanza un error de validación (THROW 50090-50099), Search lo deja en Answer.
    /// </summary>
    public class CierreAnioRepository : RepositoryBase, ICierreAnioRepository
    {
        private static SqlParameter Entero(string nombre, int? valor) =>
            new SqlParameter() { ParameterName = nombre, DbType = DbType.Int32, Value = (object?)valor ?? DBNull.Value };

        private static SqlParameter Booleano(string nombre, bool valor) =>
            new SqlParameter() { ParameterName = nombre, DbType = DbType.Boolean, Value = valor };

        private static SqlParameter Decimal(string nombre, decimal? valor) =>
            new SqlParameter() { ParameterName = nombre, SqlDbType = SqlDbType.Decimal, Precision = 5, Scale = 2, Value = (object?)valor ?? DBNull.Value };

        private static SqlParameter Texto(string nombre, string? valor) =>
            new SqlParameter() { ParameterName = nombre, DbType = DbType.String, Value = string.IsNullOrWhiteSpace(valor) ? DBNull.Value : valor.Trim() };

        private static SqlParameter[] ConEscritor(CierreAnioAccionDTO obj, params SqlParameter[] p)
        {
            var lista = new List<SqlParameter>(p)
            {
                Entero("@Usuario", obj.Usuario),
                Booleano("@PuedeCerrar", obj.PuedeCerrar)
            };
            return lista.ToArray();
        }

        private Task<Answer> Escribir(string sp, SqlParameter[] p) => Search<PR_CierreAnio_EscrituraResult>(sp, p);

        public Task<Answer> Resumen(int aniId) =>
            Search<PR_CierreAnio_ResumenResult>("app.PR_CierreAnio_Resumen", new[] { Entero("@Ani_Id", aniId) });

        public Task<Answer> Revision(int aniId) =>
            Read<PR_CierreAnio_RevisionResult>("app.PR_CierreAnio_Revision", new[] { Entero("@Ani_Id", aniId) });

        public Task<Answer> Reglas(int aniId) =>
            Read<PR_CierreAnio_ReglaResult>("app.PR_CierreAnio_Reglas", new[] { Entero("@Ani_Id", aniId) });

        public Task<Answer> Secciones(int aniId) =>
            Read<PR_CierreAnio_SeccionResult>("app.PR_CierreAnio_Secciones", new[] { Entero("@Ani_Id", aniId) });

        public Task<Answer> Resultados(int aniId, int seaId) =>
            Read<PR_CierreAnio_ResultadoResult>("app.PR_CierreAnio_Resultados", new[] { Entero("@Ani_Id", aniId), Entero("@Sea_Id", seaId) });

        public Task<Answer> Decisiones(int aniId, int seaId) =>
            Read<PR_CierreAnio_DecisionResult>("app.PR_CierreAnio_Decisiones", new[] { Entero("@Ani_Id", aniId), Entero("@Sea_Id", seaId) });

        public Task<Answer> Historial(int aniId) =>
            Read<PR_CierreAnio_HistorialResult>("app.PR_CierreAnio_Historial", new[] { Entero("@Ani_Id", aniId) });

        public Task<Answer> CambiarEstado(CierreAnioAccionDTO obj)
        {
            var p = ConEscritor(obj,
                Entero("@Ani_Id", obj.Ani_Id),
                Texto("@Accion", obj.Accion),
                Texto("@Motivo", obj.Motivo),
                Booleano("@Forzar", obj.Forzar),
                Booleano("@PuedeReabrir", obj.PuedeReabrir));
            return Escribir("app.PR_CierreAnio_CambiarEstado", p);
        }

        public Task<Answer> Calcular(CierreAnioAccionDTO obj) =>
            Escribir("app.PR_CierreAnio_Calcular", ConEscritor(obj, Entero("@Ani_Id", obj.Ani_Id)));

        public Task<Answer> GuardarRegla(CierreAnioAccionDTO obj) =>
            Escribir("app.PR_CierreAnio_GuardarRegla", ConEscritor(obj,
                Entero("@Ani_Id", obj.Ani_Id),
                Entero("@Niv_Id", obj.Niv_Id),
                Decimal("@NotaMinima", obj.NotaMinima),
                Entero("@MaxRecuperacion", obj.MaxRecuperacion)));

        public Task<Answer> Recuperacion(CierreAnioAccionDTO obj) =>
            Escribir("app.PR_CierreAnio_Recuperacion", ConEscritor(obj,
                Entero("@Rea_Id", obj.Rea_Id),
                Decimal("@Nota", obj.Nota)));

        public Task<Answer> Decidir(CierreAnioAccionDTO obj) =>
            Escribir("app.PR_CierreAnio_Decidir", ConEscritor(obj,
                Entero("@Pra_Id", obj.Pra_Id),
                Texto("@Decision", obj.Decision),
                Texto("@Motivo", obj.Motivo)));

        public Task<Answer> ConfirmarSeccion(CierreAnioAccionDTO obj) =>
            Escribir("app.PR_CierreAnio_ConfirmarSeccion", ConEscritor(obj,
                Entero("@Ani_Id", obj.Ani_Id),
                Entero("@Sea_Id", obj.Sea_Id ?? 0)));

        public Task<Answer> DeshacerSeccion(CierreAnioAccionDTO obj) =>
            Escribir("app.PR_CierreAnio_DeshacerSeccion", ConEscritor(obj,
                Entero("@Ani_Id", obj.Ani_Id),
                Entero("@Sea_Id", obj.Sea_Id ?? 0),
                Texto("@Motivo", obj.Motivo)));
    }
}
