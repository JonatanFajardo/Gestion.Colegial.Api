using Gestion.Colegial.Entities;
using System.Threading.Tasks;

namespace Gestion.Colegial.Business.Interfaces
{
    public interface IComparativoAniosService
    {
        Task<Answer> List(int AnioBase, int AnioComparacion);
    }
}
