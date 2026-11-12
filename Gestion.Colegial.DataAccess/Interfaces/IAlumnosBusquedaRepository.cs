using Gestion.Colegial.Entities;
using System.Threading.Tasks;

namespace Gestion.Colegial.DataAccess.Interfaces
{
    public interface IAlumnosBusquedaRepository
    {
        Task<Answer> Search(string Termino);
    }
}
