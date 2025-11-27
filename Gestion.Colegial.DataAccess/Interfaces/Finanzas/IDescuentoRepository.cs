using Gestion.Colegial.Entities;
using Gestion.Colegial.Entities.Entities;

namespace Gestion.Colegial.DataAccess.Interfaces.Finanzas
{
    public interface IDescuentoRepository
    {
        Task<Answer> List();
        Task<Answer> Find(int id);
        Task<Answer> Detail(int id);
        Task<Answer> Create(tbDescuentos obj);
        Task<Answer> Edit(tbDescuentos obj);
        Task<Answer> Delete(int id);
        Task<Answer> Dropdown();
    }
}
