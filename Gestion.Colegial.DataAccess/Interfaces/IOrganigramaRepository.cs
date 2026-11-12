using Gestion.Colegial.Entities;

namespace Gestion.Colegial.DataAccess.Interfaces
{
    public interface IOrganigramaRepository
    {
        Task<Answer> Get();
    }
}
