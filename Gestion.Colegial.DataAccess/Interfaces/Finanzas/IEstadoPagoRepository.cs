using Gestion.Colegial.Entities;
using Gestion.Colegial.Entities.Entities;

namespace Gestion.Colegial.DataAccess.Interfaces.Finanzas
{
    public interface IEstadoPagoRepository
    {
        Task<Answer> List();
        Task<Answer> Find(int id);
        Task<Answer> Dropdown();
    }
}
