using Gestion.Colegial.Entities;

namespace Gestion.Colegial.Business.Interfaces
{
    /// <summary>Reporte de asistencia de alumnos: resumen por sección, por alumno y planilla diaria.</summary>
    public interface IReporteAsistenciaService
    {
        Task<Answer> Anio(DateTime fecha);
        Task<Answer> Periodos(int aniId);
        Task<Answer> Filtros(int aniId, int? empId);
        Task<Answer> Secciones(int aniId, DateTime desde, DateTime hasta, int? nivId, int? cunId, int? seaId, int? empId);
        Task<Answer> SeccionInfo(int seaId);
        Task<Answer> Alumnos(int seaId, DateTime desde, DateTime hasta);
        Task<Answer> Dias(int seaId, DateTime desde, DateTime hasta);
        Task<Answer> Planilla(int seaId, DateTime desde, DateTime hasta);
    }
}
