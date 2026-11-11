using Gestion.Colegial.Entities;
using Gestion.Colegial.Entities.Entities;

namespace Gestion.Colegial.Business.Interfaces
{
    public interface IMatriculaService
    {
        Task<Answer> List(int anio);
        Task<Answer> Find(int id);
        Task<Answer> Create(tbMatriculas obj);
        Task<Answer> Edit(tbMatriculas obj);
        Task<Answer> Delete(int id);
    }
}
