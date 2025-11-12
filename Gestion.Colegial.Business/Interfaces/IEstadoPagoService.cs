using Gestion.Colegial.Entities;

namespace Gestion.Colegial.Business.Interfaces
{
    public interface IEstadoPagoService
    {
        Task<Answer> List();
        Task<Answer> Find(int id);
        Task<Answer> Dropdown();
    }
}
