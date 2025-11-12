using Gestion.Colegial.Entities;

namespace Gestion.Colegial.Business.Interfaces
{
    public interface IPagoService
    {
        Task<Answer> List();
        Task<Answer> ListByAlumno(int alumnoId);
        Task<Answer> ListByFecha(DateTime fecha);
        Task<Answer> ListByRangoFechas(DateTime fechaInicio, DateTime fechaFin);
        Task<Answer> Find(int id);
        Task<Answer> Detail(int id);
        Task<Answer> Create(object obj);
        Task<Answer> Delete(int id);
        Task<Answer> GetRecibo(int pagoId);
    }
}
