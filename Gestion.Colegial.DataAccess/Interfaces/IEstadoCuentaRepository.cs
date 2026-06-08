using Gestion.Colegial.Entities;
using System.Threading.Tasks;

namespace Gestion.Colegial.DataAccess.Interfaces
{
    public interface IEstadoCuentaRepository
    {
        Task<Answer> Find(int Alu_Id, int? Anio);
    }
}
