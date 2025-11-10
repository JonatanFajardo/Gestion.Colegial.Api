using Gestion.Colegial.Entities;
using Gestion.Colegial.Entities.DTOs;

namespace Gestion.Colegial.Business.Interfaces
{
    public interface IAlumnoService
    {
        Task<Answer> List();

        Task<Answer> Find(int id);

        Task<Answer> Detail(int id);

        Task<Answer> Create(AlumnoFindDto obj);

        Task<Answer> Edit(AlumnoFindDto obj);

        Task<Answer> Delete(int id);

        Task<Answer> NivelesEducativosDropdown();

        Task<Answer> CursosNivelesDropdown(int id);

        Task<Answer> ModalidadesDropdown(int id);

        Task<Answer> CursosDropdown(int id);

        Task<Answer> SeccionesDropdown(int id);

        Task<Answer> EstadosDropdown();
    }
}