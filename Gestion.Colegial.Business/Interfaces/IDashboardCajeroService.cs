using Gestion.Colegial.Entities;
using System.Threading.Tasks;

namespace Gestion.Colegial.Business.Interfaces
{
    public interface IDashboardCajeroService
    {
        Task<Answer> Resumen(int Usu_Id, DateTime? Fecha);
    }
}
