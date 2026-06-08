using Gestion.Colegial.Entities;
using System.Threading.Tasks;

namespace Gestion.Colegial.Business.Interfaces
{
    public interface ITopDeudoresService
    {
        Task<Answer> List(int? Top, int? Anio);
    }
}
