using Gestion.Colegial.Entities;
using System.Threading.Tasks;

namespace Gestion.Colegial.Business.Interfaces
{
    public interface IKPIsAcademicosService
    {
        Task<Answer> Find(int Anio);
    }
}
