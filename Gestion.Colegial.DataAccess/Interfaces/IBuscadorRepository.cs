using Gestion.Colegial.Entities;
using System.Threading.Tasks;

namespace Gestion.Colegial.DataAccess.Interfaces
{
    public interface IBuscadorRepository
    {
        Task<Answer> Buscar(string busqueda);
    }
}
