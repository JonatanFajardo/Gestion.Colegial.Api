using Gestion.Colegial.Entities;
using System.Threading.Tasks;

namespace Gestion.Colegial.DataAccess.Interfaces
{
    public interface IMapaAulasRepository
    {
        Task<Answer> GetMapa();
    }
}
