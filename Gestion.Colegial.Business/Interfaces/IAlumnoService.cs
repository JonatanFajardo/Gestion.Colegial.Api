using Gestion.Colegial.Business.Dtos;
using Gestion.Colegial.Entities;

namespace Gestion.Colegial.Business.Interfaces
{
    public interface IAlumnoService
    {
        Task<Answer> List();
        Task<Answer> Find(int id);
        Task<Answer> Detail(int id);
        Task<Answer> Create(AlumnosFindDto obj);
        Task<Answer> Edit(AlumnosFindDto obj);
        Task<Answer> Delete(int id);
        Task<Answer> NivelesEducativosDropdown();
        Task<Answer> CursosNivelesDropdown(int id);
        Task<Answer> ModalidadesDropdown(int id);
        Task<Answer> CursosDropdown(int id);
        Task<Answer> SeccionesDropdown(int id);
        Task<Answer> EstadosDropdown();
    }
}
