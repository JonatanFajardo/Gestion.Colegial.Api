using Gestion.Colegial.Entities;
using System.Threading.Tasks;

namespace Gestion.Colegial.DataAccess.Interfaces
{
    public interface IKPIsFinancierosRepository
    {
        Task<Answer> Find(int Anio, int? Mes);
    }
}
