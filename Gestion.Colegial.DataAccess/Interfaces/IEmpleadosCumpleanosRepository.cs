using Gestion.Colegial.Entities;
using System.Threading.Tasks;

namespace Gestion.Colegial.DataAccess.Interfaces
{
    public interface IEmpleadosCumpleanosRepository
    {
        Task<Answer> List(int? Mes);
    }
}
