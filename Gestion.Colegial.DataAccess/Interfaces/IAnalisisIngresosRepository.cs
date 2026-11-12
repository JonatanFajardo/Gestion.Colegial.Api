using Gestion.Colegial.Entities;

namespace Gestion.Colegial.DataAccess.Interfaces
{
    public interface IAnalisisIngresosRepository
    {
        Task<Answer> List(int Anio);
    }
}
