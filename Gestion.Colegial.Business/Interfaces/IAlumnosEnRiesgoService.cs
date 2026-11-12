using Gestion.Colegial.Entities;
using System.Threading.Tasks;

namespace Gestion.Colegial.Business.Interfaces
{
    public interface IAlumnosEnRiesgoService
    {
        Task<Answer> List(decimal? PromedioMinimo, int? Anio);
    }
}
