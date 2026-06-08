using Gestion.Colegial.Entities;
using System.Threading.Tasks;

namespace Gestion.Colegial.DataAccess.Interfaces
{
    public interface IDashboardCajeroRepository
    {
        Task<Answer> Resumen(int Usu_Id, DateTime? Fecha);
    }
}
