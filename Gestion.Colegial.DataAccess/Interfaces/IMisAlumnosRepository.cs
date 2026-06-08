using Gestion.Colegial.Entities;
using System.Threading.Tasks;

namespace Gestion.Colegial.DataAccess.Interfaces
{
    public interface IMisAlumnosRepository
    {
        Task<Answer> GetByHorario(int Hor_Id);
    }
}
