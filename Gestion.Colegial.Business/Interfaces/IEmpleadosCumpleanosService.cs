using Gestion.Colegial.Entities;
using System.Threading.Tasks;

namespace Gestion.Colegial.Business.Interfaces
{
    public interface IEmpleadosCumpleanosService
    {
        Task<Answer> List(int? Mes);
    }
}
