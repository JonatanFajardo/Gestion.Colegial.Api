using Gestion.Colegial.Entities;

namespace Gestion.Colegial.Business.Interfaces
{
    public interface IOrganigramaService
    {
        Task<Answer> Get();
    }
}
