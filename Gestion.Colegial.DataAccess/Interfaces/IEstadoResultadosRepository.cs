using Gestion.Colegial.Entities;

namespace Gestion.Colegial.DataAccess.Interfaces
{
    public interface IEstadoResultadosRepository
    {
        Task<Answer> Find(int Anio, int Mes);
    }
}
