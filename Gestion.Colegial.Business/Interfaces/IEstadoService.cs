using Gestion.Colegial.Entities;
using Gestion.Colegial.Entities.Entities;

namespace Gestion.Colegial.Business.Interfaces
{
    public interface IEstadoService
    {
        Task<Answer> List();

        Task<Answer> Find(int id);

        Task<Answer> Detail(int id);

        Task<Answer> Create(tbEstados obj);

        Task<Answer> Edit(tbEstados obj);

        Task<Answer> Exist(string value);

        Task<Answer> Delete(int id);
    }
}