using Gestion.Colegial.Entities;
using Gestion.Colegial.Entities.DTOs;

namespace Gestion.Colegial.Business.Interfaces
{
    /// <summary>Centro de reportes: reportes nuevos (lista de clase, saldos, ingresos, asistencia del personal) y recientes.</summary>
    public interface ICentroReportesService
    {
        Task<Answer> ListaClase(int aniId, int? nivId, int? cunId, int? seaId, bool soloActivos, DateTime hoy);
        Task<Answer> SaldosAlumno(int aniId, int? nivId, int? cunId, int? seaId, bool soloConSaldo, DateTime hoy);
        Task<Answer> IngresosConcepto(DateTime desde, DateTime hasta, int? cpaId, int? fpaId);
        Task<Answer> AsistenciaPersonal(DateTime desde, DateTime hasta);
        Task<Answer> Registrar(ReporteGeneradoDTO obj);
        Task<Answer> Recientes(int usuId, int top);
    }
}
