using Gestion.Colegial.Entities;
using Gestion.Colegial.Entities.Entities;

namespace Gestion.Colegial.Business.Interfaces
{
    public interface IPeriodoAnioService
    {
        Task<Answer> List(int anioId);
        Task<Answer> Find(int id);
        Task<Answer> Create(tbPeriodosAnio obj);
        Task<Answer> Edit(tbPeriodosAnio obj);
        Task<Answer> Delete(int id);
    }
}
