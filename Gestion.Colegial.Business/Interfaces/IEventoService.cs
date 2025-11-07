using Gestion.Colegial.Entities;
using Gestion.Colegial.Entities.Entities;

namespace Gestion.Colegial.Business.Interfaces
{
    public interface IEventoService
    {
        Task<Answer> List();
        Task<Answer> Find(int id);
        Task<Answer> Detail(int id);
        // Task<Answer> Create(tbEventos obj); // tbEventos no existe
        // Task<Answer> Edit(tbEventos obj); // tbEventos no existe
        Task<Answer> Delete(int id);
    }
}
