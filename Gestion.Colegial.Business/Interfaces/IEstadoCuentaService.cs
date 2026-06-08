using Gestion.Colegial.Entities;
using System.Threading.Tasks;

namespace Gestion.Colegial.Business.Interfaces
{
    public interface IEstadoCuentaService
    {
        Task<Answer> Find(int Alu_Id, int? Anio);
    }
}
