using Gestion.Colegial.Entities;
using System.Threading.Tasks;

namespace Gestion.Colegial.Business.Interfaces
{
    public interface IBuscadorService
    {
        Task<Answer> Buscar(string busqueda);
    }
}
