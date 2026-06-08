using Gestion.Colegial.Entities;
using System.Threading.Tasks;

namespace Gestion.Colegial.DataAccess.Interfaces
{
    public interface IFicha360EmpleadoRepository
    {
        Task<Answer> Resumen(int Emp_Id);
    }
}
