using Gestion.Colegial.Business.Dtos;
using Gestion.Colegial.Entities;

namespace Gestion.Colegial.Business.Interfaces
{
    public interface IEncargadoService
    {
        Task<Answer> List();

        Task<Answer> Find(int id);

        Task<Answer> Detail(int id);

        Task<Answer> Create(EncargadosFindDto obj);

        Task<Answer> Edit(EncargadosFindDto obj);

        Task<Answer> Delete(int id);
    }
}