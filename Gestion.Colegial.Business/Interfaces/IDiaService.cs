using Gestion.Colegial.Entities;
using Gestion.Colegial.Entities.Entities;

namespace Gestion.Colegial.Business.Interfaces
{
    public interface IDiaService
    {
        Task<Answer> List();

        Task<Answer> Find(int id);

        Task<Answer> Detail(int id);

        Task<Answer> Create(tbDias obj);

        Task<Answer> Edit(tbDias obj);

        Task<Answer> Exist(string value);

        Task<Answer> Delete(int id);
    }
}