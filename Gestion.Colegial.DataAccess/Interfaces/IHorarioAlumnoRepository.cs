using Gestion.Colegial.Entities;
using Gestion.Colegial.Entities.Entities;

namespace Gestion.Colegial.DataAccess.Interfaces
{
    public interface IHorarioAlumnoRepository
    {
        Task<Answer> List();
        Task<Answer> Find(int id);
        Task<Answer> Detail(int id);
        Task<Answer> Create(tbHorarioAlumnos obj);
        Task<Answer> Edit(tbHorarioAlumnos obj);
        Task<Answer> Delete(int id);
    }
}
