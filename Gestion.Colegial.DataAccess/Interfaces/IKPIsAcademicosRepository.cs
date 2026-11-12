using Gestion.Colegial.Entities;
using System.Threading.Tasks;

namespace Gestion.Colegial.DataAccess.Interfaces
{
    public interface IKPIsAcademicosRepository
    {
        Task<Answer> Find(int Anio);
    }
}
