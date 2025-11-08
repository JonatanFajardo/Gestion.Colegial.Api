using Gestion.Colegial.Entities;
using Gestion.Colegial.Entities.Entities;

namespace Gestion.Colegial.Business.Interfaces
{
    public interface IHoraService
    {
        Task<Answer> List();

        Task<Answer> Find(int id);

        Task<Answer> Create(tbHoras obj);

        Task<Answer> Edit(tbHoras obj);

        Task<Answer> Exist(string value);

        Task<Answer> Delete(int id);
    }
}