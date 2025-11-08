using Gestion.Colegial.Entities;
using Gestion.Colegial.Entities.Entities;

namespace Gestion.Colegial.DataAccess.Interfaces
{
    public interface IMateriaRepository
    {
        Task<Answer> List();

        Task<Answer> Find(int id);

        Task<Answer> Detail(int id);

        Task<Answer> Create(tbMaterias obj);

        Task<Answer> Edit(tbMaterias obj);

        Task<Answer> Exist(string value);

        Task<Answer> Delete(int id);
    }
}