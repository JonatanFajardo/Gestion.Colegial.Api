using Gestion.Colegial.Entities;
using System.Threading.Tasks;

namespace Gestion.Colegial.Business.Interfaces
{
    public interface IFicha360EmpleadoService
    {
        Task<Answer> Resumen(int Emp_Id);
    }
}
