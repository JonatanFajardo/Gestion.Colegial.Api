using Gestion.Colegial.DataAccess.Interfaces;
using Gestion.Colegial.Entities;
using Gestion.Colegial.Entities.DTOs;
using Gestion.Colegial.Entities.Entities;
using System.Data;
using System.Data.SqlClient;

namespace Gestion.Colegial.DataAccess.Repositories
{
    /// <summary>Centro de reportes (script 081). Lecturas con Read; el registro devuelve el Id nuevo.</summary>
    public class CentroReportesRepository : RepositoryBase, ICentroReportesRepository
    {
        private static SqlParameter Entero(string nombre, int? valor) =>
            new SqlParameter() { ParameterName = nombre, SqlDbType = SqlDbType.Int, Value = (object?)valor ?? DBNull.Value };

        private static SqlParameter Fecha(string nombre, DateTime valor) =>
            new SqlParameter() { ParameterName = nombre, SqlDbType = SqlDbType.Date, Value = valor.Date };

        private static SqlParameter Bit(string nombre, bool valor) =>
            new SqlParameter() { ParameterName = nombre, SqlDbType = SqlDbType.Bit, Value = valor };

        private static SqlParameter Texto(string nombre, string? valor, int largo) =>
            new SqlParameter() { ParameterName = nombre, SqlDbType = SqlDbType.NVarChar, Size = largo, Value = (object?)valor ?? DBNull.Value };

        private static SqlParameter[] Ubicacion(int aniId, int? nivId, int? cunId, int? seaId, SqlParameter extra, DateTime hoy) =>
            new[] { Entero("@Ani_Id", aniId), Entero("@Niv_Id", nivId), Entero("@Cun_Id", cunId), Entero("@Sea_Id", seaId), extra, Fecha("@Hoy", hoy) };

        public async Task<Answer> ListaClase(int aniId, int? nivId, int? cunId, int? seaId, bool soloActivos, DateTime hoy) =>
            await Read<PR_CentroReportes_ListaClaseResult>("app.PR_CentroReportes_ListaClase",
                Ubicacion(aniId, nivId, cunId, seaId, Bit("@SoloActivos", soloActivos), hoy));

        public async Task<Answer> SaldosAlumno(int aniId, int? nivId, int? cunId, int? seaId, bool soloConSaldo, DateTime hoy) =>
            await Read<PR_CentroReportes_SaldosAlumnoResult>("app.PR_CentroReportes_SaldosAlumno",
                Ubicacion(aniId, nivId, cunId, seaId, Bit("@SoloConSaldo", soloConSaldo), hoy));

        public async Task<Answer> IngresosConcepto(DateTime desde, DateTime hasta, int? cpaId, int? fpaId) =>
            await Read<PR_CentroReportes_IngresosConceptoResult>("app.PR_CentroReportes_IngresosConcepto",
                new[] { Fecha("@Desde", desde), Fecha("@Hasta", hasta), Entero("@Cpa_Id", cpaId), Entero("@Fpa_Id", fpaId) });

        public async Task<Answer> AsistenciaPersonal(DateTime desde, DateTime hasta) =>
            await Read<PR_CentroReportes_AsistenciaPersonalResult>("app.PR_CentroReportes_AsistenciaPersonal",
                new[] { Fecha("@Desde", desde), Fecha("@Hasta", hasta) });

        public async Task<Answer> ComparativoCobros(int anioBase, int anioComparado) =>
            await Read<PR_CentroReportes_ComparativoCobrosResult>("app.PR_CentroReportes_ComparativoCobros",
                new[] { Entero("@AnioBase", anioBase), Entero("@AnioComparado", anioComparado) });

        public async Task<Answer> ProyeccionCobros(int anio, int mesDesde) =>
            await Read<PR_CentroReportes_ProyeccionCobrosResult>("app.PR_CentroReportes_ProyeccionCobros",
                new[] { Entero("@Anio", anio), Entero("@MesDesde", mesDesde) });

        public async Task<Answer> Registrar(ReporteGeneradoDTO obj)
        {
            SqlParameter[] p =
            {
                Entero("@Usu_Id", obj.Usu_Id),
                Texto("@Rge_Clave", obj.Rge_Clave, 60),
                Texto("@Rge_Titulo", obj.Rge_Titulo, 150),
                Texto("@Rge_Parametros", obj.Rge_Parametros, 2000),
                Texto("@Rge_Resumen", obj.Rge_Resumen, 500),
                new SqlParameter() { ParameterName = "@Rge_Estado", SqlDbType = SqlDbType.VarChar, Size = 10, Value = (object?)obj.Rge_Estado ?? DBNull.Value },
                Entero("@Rge_Filas", obj.Rge_Filas),
                Texto("@Rge_Error", obj.Rge_Error, 400),
                new SqlParameter() { ParameterName = "@Rge_Fecha", SqlDbType = SqlDbType.DateTime2, Value = (object?)obj.Rge_Fecha ?? DBNull.Value }
            };
            return await NewWithId<PR_tbReportesGenerados_RegistrarResult>("app.PR_tbReportesGenerados_Registrar", p);
        }

        public async Task<Answer> Recientes(int usuId, int top) =>
            await Read<PR_tbReportesGenerados_RecientesResult>("app.PR_tbReportesGenerados_Recientes",
                new[] { Entero("@Usu_Id", usuId), Entero("@Top", top) });
    }
}
