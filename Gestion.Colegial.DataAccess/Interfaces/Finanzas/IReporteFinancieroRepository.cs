using Gestion.Colegial.Entities;

namespace Gestion.Colegial.DataAccess.Interfaces.Finanzas
{
    public interface IReporteFinancieroRepository
    {
        Task<Answer> IngresosPorMes(int anio, int mes);
        Task<Answer> ProyeccionCobros(int anio, int mes);
        Task<Answer> ListadoMorosos();
        Task<Answer> EstadoCuentaAlumno(int alumnoId);
        Task<Answer> ComparativaAnual(int anioInicio, int anioFin);
    }
}
