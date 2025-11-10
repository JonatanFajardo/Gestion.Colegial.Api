using Gestion.Colegial.Entities;
using Gestion.Colegial.Entities.DTOs;

namespace Gestion.Colegial.Business.Interfaces
{
    public interface IEmpleadoService
    {
        Task<Answer> List();

        Task<Answer> Find(int id);

        Task<Answer> Detail(int id);

        Task<Answer> Create(EmpleadoFindDto obj);

        Task<Answer> Edit(EmpleadoFindDto obj);

        Task<Answer> TitulosDropdown();

        Task<Answer> CargosDropdown();

        Task<Answer> Delete(int id);
    }
}