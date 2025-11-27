using Gestion.Colegial.Entities;

namespace Gestion.Colegial.Business.Interfaces.ModuloFinanzas
{
    public interface IConceptoPagoService
    {
        Task<Answer> List();
        Task<Answer> Find(int id);
        Task<Answer> Detail(int id);
        Task<Answer> Create(object obj);
        Task<Answer> Edit(object obj);
        Task<Answer> Delete(int id);
        Task<Answer> Dropdown();
    }
}
