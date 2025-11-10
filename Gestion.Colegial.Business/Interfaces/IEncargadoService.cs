using Gestion.Colegial.Entities;
using Gestion.Colegial.Entities.DTOs;

namespace Gestion.Colegial.Business.Interfaces
{
    public interface IEncargadoService
    {
        Task<Answer> List();

        Task<Answer> Find(int id);

        Task<Answer> Detail(int id);

        Task<Answer> Create(EncargadoFindDto obj);

        Task<Answer> Edit(EncargadoFindDto obj);

        Task<Answer> Delete(int id);
    }
}