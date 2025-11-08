using Gestion.Colegial.Entities;

namespace Gestion.Colegial.Business.Interfaces
{
    public interface IEventoService
    {
        Task<Answer> List();

        Task<Answer> Find(int id);

        Task<Answer> Detail(int id);

        Task<Answer> Delete(int id);
    }
}