using Gestion.Colegial.Entities;
using System.Threading.Tasks;

namespace Gestion.Colegial.Business.Interfaces
{
    public interface IDashboardDocenteService
    {
        Task<Answer> Resumen(int Emp_Id, int Dia_Id, int Anio);
    }
}
