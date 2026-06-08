using Gestion.Colegial.Entities;

namespace Gestion.Colegial.Business.Interfaces
{
    public interface IAnalisisIngresosService
    {
        Task<Answer> List(int Anio);
    }
}
