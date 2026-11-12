using Gestion.Colegial.Entities;
using System.Threading.Tasks;

namespace Gestion.Colegial.DataAccess.Interfaces
{
    public interface ISesionesActivasRepository
    {
        Task<Answer> List();
    }
}
