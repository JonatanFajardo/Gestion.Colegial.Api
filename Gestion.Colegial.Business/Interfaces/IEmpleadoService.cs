using Gestion.Colegial.Business.Dtos;
using Gestion.Colegial.Entities;

namespace Gestion.Colegial.Business.Interfaces
{
    public interface IEmpleadoService
    {
        Task<Answer> List();
        Task<Answer> Find(int id);
        Task<Answer> Detail(int id);
        Task<Answer> Create(EmpleadosFindDto obj);
        Task<Answer> Edit(EmpleadosFindDto obj);
        Task<Answer> TitulosDropdown();
        Task<Answer> CargosDropdown();
        Task<Answer> Delete(int id);
    }
}
