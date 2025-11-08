using Gestion.Colegial.Entities;

namespace Gestion.Colegial.DataAccess.Interfaces
{
    public interface IEventoRepository
    {
        Task<Answer> List();

        Task<Answer> Find(int id);

        Task<Answer> Detail(int id);

        Task<Answer> Delete(int id);
    }
}