using Gestion.Colegial.Entities;
using Gestion.Colegial.Entities.Entities;

namespace Gestion.Colegial.DataAccess.Interfaces
{
    public interface IOfertaAnioRepository
    {
        Task<Answer> List(int aniId);
        Task<Answer> Find(int id);
        Task<Answer> Create(tbOfertasAnio obj);
        Task<Answer> Edit(tbOfertasAnio obj);
        Task<Answer> Delete(int id);
    }
}
