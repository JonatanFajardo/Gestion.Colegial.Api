using Gestion.Colegial.Entities;
using Gestion.Colegial.Entities.DTOs;

namespace Gestion.Colegial.DataAccess.Interfaces
{
    /// <summary>Centro de reportes (script 081): reportes nuevos y registro de reportes generados.</summary>
    public interface ICentroReportesRepository
    {
        Task<Answer> ListaClase(int aniId, int? nivId, int? cunId, int? seaId, bool soloActivos, DateTime hoy);
        Task<Answer> SaldosAlumno(int aniId, int? nivId, int? cunId, int? seaId, bool soloConSaldo, DateTime hoy);
        Task<Answer> IngresosConcepto(DateTime desde, DateTime hasta, int? cpaId, int? fpaId);
        Task<Answer> AsistenciaPersonal(DateTime desde, DateTime hasta);
        Task<Answer> ComparativoCobros(int anioBase, int anioComparado);
        Task<Answer> ProyeccionCobros(int anio, int mesDesde);
        Task<Answer> Registrar(ReporteGeneradoDTO obj);
        Task<Answer> Recientes(int usuId, int top);
    }
}
