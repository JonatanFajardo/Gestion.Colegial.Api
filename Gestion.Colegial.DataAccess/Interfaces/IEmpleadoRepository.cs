using Gestion.Colegial.Entities;
using Gestion.Colegial.Entities.Entities;

namespace Gestion.Colegial.DataAccess.Interfaces
{
    public interface IEmpleadoRepository
    {
        Task<Answer> List();
        Task<Answer> Find(int id);
        Task<Answer> Detail(int id);
        Task<Answer> Create(tbEmpleados obj);
        Task<Answer> Edit(tbEmpleados obj);
        Task<Answer> Delete(int id);
        Task<Answer> TitulosDropdown();
        Task<Answer> CargosDropdown();
        Task<Answer> ModalidadesDropdown();
    }
}
