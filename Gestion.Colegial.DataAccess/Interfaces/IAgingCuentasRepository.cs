using Gestion.Colegial.Entities;
using System.Threading.Tasks;

namespace Gestion.Colegial.DataAccess.Interfaces
{
    public interface IAgingCuentasRepository
    {
        Task<Answer> List(DateTime? FechaCorte);
    }
}
