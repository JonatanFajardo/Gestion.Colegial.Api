using Gestion.Colegial.Entities;
using System.Threading.Tasks;

namespace Gestion.Colegial.DataAccess.Interfaces
{
    public interface ITopDeudoresRepository
    {
        Task<Answer> List(int? Top, int? Anio);
    }
}
