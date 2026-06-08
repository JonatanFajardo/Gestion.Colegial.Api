using Gestion.Colegial.Entities;
using System.Threading.Tasks;

namespace Gestion.Colegial.DataAccess.Interfaces
{
    public interface IDashboardDocenteRepository
    {
        Task<Answer> Resumen(int Emp_Id, int Dia_Id, int Anio);
    }
}
