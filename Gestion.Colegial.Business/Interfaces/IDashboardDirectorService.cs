using Gestion.Colegial.Entities;
using System.Threading.Tasks;

namespace Gestion.Colegial.Business.Interfaces
{
    public interface IDashboardDirectorService
    {
        Task<Answer> Resumen(int Anio, int Mes);
    }
}
