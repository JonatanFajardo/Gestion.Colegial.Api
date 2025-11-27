using Gestion.Colegial.Entities;
using Gestion.Colegial.Entities.Entities;

namespace Gestion.Colegial.DataAccess.Interfaces.Finanzas
{
    public interface IConceptoPagoRepository
    {
        Task<Answer> List();
        Task<Answer> Find(int id);
        Task<Answer> Detail(int id);
        Task<Answer> Create(tbConceptosPago obj);
        Task<Answer> Edit(tbConceptosPago obj);
        Task<Answer> Delete(int id);
        Task<Answer> Dropdown();
    }
}
