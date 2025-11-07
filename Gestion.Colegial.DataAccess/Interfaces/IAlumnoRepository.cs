using Gestion.Colegial.Entities;
using Gestion.Colegial.Entities.Entities;

namespace Gestion.Colegial.DataAccess.Interfaces
{
    public interface IAlumnoRepository
    {
        Task<Answer> List();
        Task<Answer> Find(int id);
        Task<Answer> Detail(int id);
        Task<Answer> Create(tbAlumnos obj);
        Task<Answer> Edit(tbAlumnos obj);
        Task<Answer> Delete(int id);
        Task<Answer> NivelesEducativosDropdown();
        Task<Answer> CursosNivelesDropdown(int id);
        Task<Answer> ModalidadesDropdown(int id);
        Task<Answer> CursosDropdown(int id);
        Task<Answer> SeccionesDropdown(int id);
        Task<Answer> EstadosDropdown();
    }
}
