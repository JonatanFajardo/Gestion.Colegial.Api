using Gestion.Colegial.Entities;
using Gestion.Colegial.Entities.Entities;

namespace Gestion.Colegial.Business.Interfaces
{
    public interface ICargoService
    {
        Task<Answer> List();
        Task<Answer> Find(int id);
        Task<Answer> Detail(int id);
        Task<Answer> Create(tbCargos obj);
        Task<Answer> Edit(tbCargos obj);
        Task<Answer> Exist(string value);
        Task<Answer> Delete(int id);
    }
}
