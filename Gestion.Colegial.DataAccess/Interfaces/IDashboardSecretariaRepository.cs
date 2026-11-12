using Gestion.Colegial.Entities;
using System.Threading.Tasks;

namespace Gestion.Colegial.DataAccess.Interfaces
{
    public interface IDashboardSecretariaRepository
    {
        Task<Answer> Resumen(int Anio);
    }
}
