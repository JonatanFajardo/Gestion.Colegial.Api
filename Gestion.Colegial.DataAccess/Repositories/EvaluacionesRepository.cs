using Gestion.Colegial.DataAccess.Interfaces;
using Gestion.Colegial.Entities;
using Gestion.Colegial.Entities.DTOs;
using Gestion.Colegial.Entities.Entities;
using System.Data;
using System.Data.SqlClient;

namespace Gestion.Colegial.DataAccess.Repositories
{
    /// <summary>
    /// Notas ponderadas (script 089). Toda lectura y escritura lleva el usuario: el procedimiento revisa
    /// sus permisos y, si es docente, que el grupo esté en su horario. Las escrituras devuelven una fila
    /// (Id, Cev_Id, Cantidad...), por eso usan Search; si el procedimiento lanza un error, queda en Answer.
    /// </summary>
    public class EvaluacionesRepository : RepositoryBase, IEvaluacionesRepository
    {
        private static SqlParameter Entero(string nombre, int? valor) =>
            new SqlParameter() { ParameterName = nombre, DbType = DbType.Int32, Value = (object?)valor ?? DBNull.Value };

        private static SqlParameter Decimal(string nombre, decimal valor) =>
            new SqlParameter() { ParameterName = nombre, SqlDbType = SqlDbType.Decimal, Precision = 9, Scale = 2, Value = valor };

        private static SqlParameter Bit(string nombre, bool valor) =>
            new SqlParameter() { ParameterName = nombre, DbType = DbType.Boolean, Value = valor };

        private static SqlParameter Fecha(string nombre, DateTime? valor) =>
            new SqlParameter() { ParameterName = nombre, DbType = DbType.Date, Value = valor.HasValue ? valor.Value.Date : DBNull.Value };

        private static SqlParameter Texto(string nombre, string? valor, DbType tipo = DbType.String) =>
            new SqlParameter() { ParameterName = nombre, DbType = tipo, Value = string.IsNullOrWhiteSpace(valor) ? DBNull.Value : valor.Trim() };

        private static SqlParameter Usuario(EvaluacionEscritorDTO obj) => Entero("@Usuario", obj.Usuario);

        private Task<Answer> Escribir(string procedimiento, SqlParameter[] parametros) =>
            Search<PR_Evaluacion_EscrituraResult>(procedimiento, parametros);

        public Task<Answer> Cuaderno(int horId, int pacId, int usuId) =>
            Search<PR_Evaluacion_JsonResult>("app.PR_Evaluacion_Cuaderno",
                new[] { Entero("@Hor_Id", horId), Entero("@Pac_Id", pacId), Entero("@Usu_Id", usuId) });

        public Task<Answer> UsaActividades(int horId, int pacId) =>
            Search<PR_Evaluacion_UsaActividadesResult>("app.PR_Evaluacion_UsaActividades",
                new[] { Entero("@Hor_Id", horId), Entero("@Pac_Id", pacId) });

        public Task<Answer> UsaActividadesNota(int notId) =>
            Search<PR_Evaluacion_UsaActividadesResult>("app.PR_Evaluacion_UsaActividadesNota", new[] { Entero("@Not_Id", notId) });

        public Task<Answer> ActualizarNotas(int cevId, int usuId) =>
            Escribir("app.PR_Evaluacion_ActualizarNotas", new[] { Entero("@Cev_Id", cevId), Entero("@Usuario", usuId) });

        public Task<Answer> GuardarActividad(ActividadEvaluacionGuardarDTO obj) => Escribir("app.PR_Evaluacion_GuardarActividad", new[]
        {
            Entero("@Act_Id", obj.Act_Id > 0 ? obj.Act_Id : null), Entero("@Hor_Id", obj.Hor_Id), Entero("@Pac_Id", obj.Pac_Id),
            Entero("@Cet_Id", obj.Cet_Id), Entero("@Plt_Id", obj.Plt_Id), Texto("@Nombre", obj.Nombre), Texto("@Descripcion", obj.Descripcion),
            Decimal("@PuntosMax", obj.PuntosMax), Fecha("@Fecha", obj.Fecha), Bit("@NoCuenta", obj.NoCuenta),
            Entero("@Version", obj.Version), Texto("@Otras", obj.Otras), Usuario(obj)
        });

        public Task<Answer> QuitarActividad(ActividadEvaluacionQuitarDTO obj) => Escribir("app.PR_Evaluacion_QuitarActividad", new[]
        {
            Entero("@Act_Id", obj.Act_Id), Entero("@Version", obj.Version), Usuario(obj)
        });

        public Task<Answer> GuardarPuntos(PuntosEvaluacionGuardarDTO obj) => Escribir("app.PR_Evaluacion_GuardarPuntos", new[]
        {
            Entero("@Cev_Id", obj.Cev_Id), Texto("@Puntos", obj.Puntos), Usuario(obj)
        });

        public Task<Answer> Plantillas(int anio, int usuId) =>
            Read<PR_Evaluacion_PlantillaResult>("app.PR_Evaluacion_Plantillas", new[] { Entero("@Anio", anio), Entero("@Usu_Id", usuId) });

        public Task<Answer> Opciones(int usuId, string tipo, int? anio, int? nivId) =>
            Read<PR_Evaluacion_OpcionResult>("app.PR_Evaluacion_Opciones", new[]
            {
                Entero("@Usu_Id", usuId), Texto("@Tipo", tipo, DbType.AnsiString), Entero("@Anio", anio), Entero("@Niv_Id", nivId)
            });

        public Task<Answer> GuardarPlantilla(PlantillaEvaluacionGuardarDTO obj) => Escribir("app.PR_Evaluacion_GuardarPlantilla", new[]
        {
            Entero("@Ple_Id", obj.Ple_Id > 0 ? obj.Ple_Id : null), Entero("@Anio", obj.Anio), Entero("@Niv_Id", obj.Niv_Id),
            Entero("@Mat_Id", obj.Mat_Id), Texto("@Nombre", obj.Nombre), Texto("@Descripcion", obj.Descripcion),
            Texto("@Tipos", obj.Tipos), Entero("@Version", obj.Version), Usuario(obj)
        });

        public Task<Answer> QuitarPlantilla(PlantillaEvaluacionQuitarDTO obj) => Escribir("app.PR_Evaluacion_QuitarPlantilla", new[]
        {
            Entero("@Ple_Id", obj.Ple_Id), Entero("@Version", obj.Version), Usuario(obj)
        });

        public Task<Answer> Avance(int anio, int semId, int pacId, int usuId) =>
            Read<PR_Evaluacion_AvanceResult>("app.PR_Evaluacion_Avance", new[]
            {
                Entero("@Anio", anio), Entero("@Sem_Id", semId), Entero("@Pac_Id", pacId), Entero("@Usu_Id", usuId)
            });
    }
}
