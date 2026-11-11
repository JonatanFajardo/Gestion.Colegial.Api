using Gestion.Colegial.Entities;
using Gestion.Colegial.Entities.Entities;

namespace Gestion.Colegial.DataAccess.Interfaces
{
    public interface ISeccionAnioRepository
    {
        Task<Answer> List(int aniId);
        Task<Answer> Find(int id);
        Task<Answer> Create(tbSeccionesAnio obj);
        Task<Answer> Edit(tbSeccionesAnio obj);
        Task<Answer> Delete(int id);
    }
}
