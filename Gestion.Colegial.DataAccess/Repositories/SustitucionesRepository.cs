using Gestion.Colegial.DataAccess.Interfaces;
using Gestion.Colegial.Entities;
using Gestion.Colegial.Entities.DTOs;
using Gestion.Colegial.Entities.Entities;
using System.Data;
using System.Data.SqlClient;

namespace Gestion.Colegial.DataAccess.Repositories
{
    /// <summary>
    /// Sustitución de docente (script 073). Las escrituras devuelven una fila { Id, Estado }, por eso
    /// usan Search: si el procedimiento lanza un error, queda en Answer (Incidents) y no se relanza.
    /// empId = alcance: null ve todo; un número, solo lo de ese docente.
    /// </summary>
    public class SustitucionesRepository : RepositoryBase, ISustitucionesRepository
    {
        private static SqlParameter Entero(string nombre, int? valor) =>
            new SqlParameter() { ParameterName = nombre, DbType = DbType.Int32, Value = (object?)valor ?? DBNull.Value };

        private static SqlParameter Booleano(string nombre, bool valor) =>
            new SqlParameter() { ParameterName = nombre, DbType = DbType.Boolean, Value = valor };

        private static SqlParameter Fecha(string nombre, DateTime? valor) =>
            new SqlParameter() { ParameterName = nombre, DbType = DbType.Date, Value = valor.HasValue ? valor.Value.Date : DBNull.Value };

        private static SqlParameter Texto(string nombre, string? valor) =>
            new SqlParameter() { ParameterName = nombre, DbType = DbType.String, Value = string.IsNullOrWhiteSpace(valor) ? DBNull.Value : valor.Trim() };

        private static IEnumerable<SqlParameter> Escritor(SustitucionEscritorDTO obj)
        {
            yield return Entero("@Usuario", obj.Usuario);
            yield return Booleano("@PuedeAsignar", obj.PuedeAsignar);
        }

        public async Task<Answer> Dia(DateTime fecha, int? empId) =>
            await Read<PR_tbSustituciones_DiaResult>("app.PR_tbSustituciones_Dia", new[] { Fecha("@Fecha", fecha), Entero("@Emp_Id", empId) });

        public async Task<Answer> Mes(DateTime fecha, int? empId) =>
            await Search<PR_tbSustituciones_MesResult>("app.PR_tbSustituciones_Mes", new[] { Fecha("@Fecha", fecha), Entero("@Emp_Id", empId) });

        public async Task<Answer> Sugerencias(int horId, DateTime fecha) =>
            await Read<PR_tbSustituciones_SugerenciasResult>("app.PR_tbSustituciones_Sugerencias", new[] { Entero("@Hor_Id", horId), Fecha("@Fecha", fecha) });

        public async Task<Answer> Docentes(DateTime fecha) =>
            await Read<PR_tbSustituciones_DocentesResult>("app.PR_tbSustituciones_Docentes", new[] { Fecha("@Fecha", fecha) });

        public async Task<Answer> Historial(DateTime desde, DateTime hasta, int? empId) =>
            await Read<PR_tbSustituciones_HistorialResult>("app.PR_tbSustituciones_Historial",
                new[] { Fecha("@Desde", desde), Fecha("@Hasta", hasta), Entero("@Emp_Id", empId) });

        public async Task<Answer> Asignar(SustitucionAsignarDTO obj)
        {
            var p = new List<SqlParameter>
            {
                Entero("@Hor_Id", obj.Hor_Id),
                Fecha("@Sus_Fecha", obj.Sus_Fecha),
                Entero("@Emp_IdSuplente", obj.Emp_IdSuplente),
                Texto("@Sus_Notas", obj.Sus_Notas)
            };
            p.AddRange(Escritor(obj));
            return await Search<PR_tbSustituciones_EscrituraResult>("app.PR_tbSustituciones_Asignar", p.ToArray());
        }

        public async Task<Answer> Cancelar(SustitucionCancelarDTO obj)
        {
            var p = new List<SqlParameter> { Entero("@Sus_Id", obj.Sus_Id), Texto("@Motivo", obj.Motivo) };
            p.AddRange(Escritor(obj));
            return await Search<PR_tbSustituciones_EscrituraResult>("app.PR_tbSustituciones_Cancelar", p.ToArray());
        }

        public async Task<Answer> MarcarAusencia(AusenciaDocenteMarcarDTO obj)
        {
            var p = new List<SqlParameter>
            {
                Entero("@Emp_Id", obj.Emp_Id),
                Fecha("@Aud_Fecha", obj.Aud_Fecha),
                Texto("@Aud_Motivo", obj.Aud_Motivo)
            };
            p.AddRange(Escritor(obj));
            return await Search<PR_tbSustituciones_EscrituraResult>("app.PR_tbAusenciasDocentes_Marcar", p.ToArray());
        }

        public async Task<Answer> QuitarAusencia(AusenciaDocenteQuitarDTO obj)
        {
            var p = new List<SqlParameter> { Entero("@Aud_Id", obj.Aud_Id) };
            p.AddRange(Escritor(obj));
            return await Search<PR_tbSustituciones_EscrituraResult>("app.PR_tbAusenciasDocentes_Quitar", p.ToArray());
        }
    }
}
