using Gestion.Colegial.Entities;

namespace Gestion.Colegial.Business.Interfaces
{
    public interface IFormaPagoService
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
