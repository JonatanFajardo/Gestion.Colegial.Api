using Gestion.Colegial.Entities;

namespace Gestion.Colegial.Business.Interfaces
{
    public interface IEstadoResultadosService
    {
        Task<Answer> Find(int Anio, int Mes);
    }
}
