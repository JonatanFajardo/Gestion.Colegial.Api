using Gestion.Colegial.Entities;
using Gestion.Colegial.Entities.Entities;

namespace Gestion.Colegial.Business.Interfaces
{
    public interface IEnfoqueAnioService
    {
        Task<Answer> Find(int id);
        Task<Answer> Set(tbEnfoqueAnio obj);
    }
}
