using Gestion.Colegial.Entities;
using System.Threading.Tasks;

namespace Gestion.Colegial.Business.Interfaces
{
    public interface IDashboardAdminService
    {
        Task<Answer> Resumen();
    }
}
