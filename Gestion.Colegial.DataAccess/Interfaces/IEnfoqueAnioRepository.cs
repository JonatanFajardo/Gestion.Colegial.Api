using Gestion.Colegial.Entities;
using Gestion.Colegial.Entities.Entities;

namespace Gestion.Colegial.DataAccess.Interfaces
{
    public interface IEnfoqueAnioRepository
    {
        Task<Answer> Find(int id);
        Task<Answer> Set(tbEnfoqueAnio obj);
    }
}
