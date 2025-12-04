using Gestion.Colegial.Entities;
using Gestion.Colegial.Entities.Entities;

namespace Gestion.Colegial.DataAccess.Interfaces
{
    public interface ICursoNivelRepository
    {
        Task<Answer> List();
        Task<Answer> Find(int id);
        Task<Answer> Detail(int id);
        Task<Answer> Create(tbCursosNiveles obj);
        Task<Answer> Edit(tbCursosNiveles obj);
        Task<Answer> Exist(string value);
        Task<Answer> Delete(int id);
        Task<Answer> CursosNivelesDropdown(int id);
    }
}
