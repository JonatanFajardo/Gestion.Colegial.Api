using Gestion.Colegial.Entities;
using Gestion.Colegial.Entities.Entities;

namespace Gestion.Colegial.DataAccess.Interfaces
{
    public interface IPagoRepository
    {
        Task<Answer> List();
        Task<Answer> ListByAlumno(int alumnoId);
        Task<Answer> ListByFecha(DateTime fecha);
        Task<Answer> ListByRangoFechas(DateTime fechaInicio, DateTime fechaFin);
        Task<Answer> Find(int id);
        Task<Answer> Detail(int id);
        Task<Answer> Create(tbPagos obj);
        Task<Answer> Delete(int id);
        Task<Answer> GetRecibo(int pagoId);
    }
}
