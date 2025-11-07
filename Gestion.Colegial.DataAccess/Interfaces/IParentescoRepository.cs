using Gestion.Colegial.Entities;
using Gestion.Colegial.Entities.Entities;

namespace Gestion.Colegial.DataAccess.Interfaces
{
    public interface IParentescoRepository
    {
        Task<Answer> List();
        Task<Answer> Find(int id);
        Task<Answer> Detail(int id);
        Task<Answer> Create(tbParentescos obj);
        Task<Answer> Edit(tbParentescos obj);
        Task<Answer> Exist(string value);
        Task<Answer> Delete(int id);
    }
}
