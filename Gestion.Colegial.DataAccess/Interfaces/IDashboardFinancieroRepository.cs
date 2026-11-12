using Gestion.Colegial.Entities;
using System.Threading.Tasks;

namespace Gestion.Colegial.DataAccess.Interfaces
{
    public interface IDashboardFinancieroRepository
    {
        Task<Answer> Resumen(int Anio, int Mes);
    }
}
