using Gestion.Colegial.Entities;

namespace Gestion.Colegial.DataAccess.Interfaces
{
    public interface IFlujoCajaRepository
    {
        Task<Answer> List(int Anio);
    }
}
