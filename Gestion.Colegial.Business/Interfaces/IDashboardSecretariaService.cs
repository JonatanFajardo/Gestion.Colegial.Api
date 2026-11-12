using Gestion.Colegial.Entities;
using System.Threading.Tasks;

namespace Gestion.Colegial.Business.Interfaces
{
    public interface IDashboardSecretariaService
    {
        Task<Answer> Resumen(int Anio);
    }
}
