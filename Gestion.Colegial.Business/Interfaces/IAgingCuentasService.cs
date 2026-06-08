using Gestion.Colegial.Entities;
using System.Threading.Tasks;

namespace Gestion.Colegial.Business.Interfaces
{
    public interface IAgingCuentasService
    {
        Task<Answer> List(DateTime? FechaCorte);
    }
}
