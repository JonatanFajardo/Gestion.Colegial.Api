using Gestion.Colegial.Entities;
using System.Threading.Tasks;

namespace Gestion.Colegial.DataAccess.Interfaces
{
    public interface IDashboardConsultaRepository
    {
        Task<Answer> Resumen(int Anio);
    }
}
