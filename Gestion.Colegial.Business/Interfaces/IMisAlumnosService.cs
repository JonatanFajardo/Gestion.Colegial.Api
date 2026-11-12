using Gestion.Colegial.Entities;
using System.Threading.Tasks;

namespace Gestion.Colegial.Business.Interfaces
{
    public interface IMisAlumnosService
    {
        Task<Answer> GetByHorario(int Hor_Id);
    }
}
