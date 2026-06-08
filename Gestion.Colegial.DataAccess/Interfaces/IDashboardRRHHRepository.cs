using Gestion.Colegial.Entities;
using System.Threading.Tasks;

namespace Gestion.Colegial.DataAccess.Interfaces
{
    public interface IDashboardRRHHRepository
    {
        Task<Answer> Resumen(int Anio, int Mes);
    }
}
