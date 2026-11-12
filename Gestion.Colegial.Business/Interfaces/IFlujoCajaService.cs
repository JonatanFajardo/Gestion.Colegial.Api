using Gestion.Colegial.Entities;

namespace Gestion.Colegial.Business.Interfaces
{
    public interface IFlujoCajaService
    {
        Task<Answer> List(int Anio);
    }
}
