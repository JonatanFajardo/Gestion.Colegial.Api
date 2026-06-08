using Gestion.Colegial.Entities;
using System.Threading.Tasks;

namespace Gestion.Colegial.DataAccess.Interfaces
{
    public interface IComparativoAniosRepository
    {
        Task<Answer> List(int AnioBase, int AnioComparacion);
    }
}
