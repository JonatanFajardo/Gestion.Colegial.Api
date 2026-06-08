using Gestion.Colegial.Entities;
using System.Threading.Tasks;

namespace Gestion.Colegial.DataAccess.Interfaces
{
    public interface IAlumnosEnRiesgoRepository
    {
        Task<Answer> List(decimal? PromedioMinimo, int? Anio);
    }
}
