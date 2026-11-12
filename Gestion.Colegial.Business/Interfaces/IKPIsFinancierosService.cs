using Gestion.Colegial.Entities;
using System.Threading.Tasks;

namespace Gestion.Colegial.Business.Interfaces
{
    public interface IKPIsFinancierosService
    {
        Task<Answer> Find(int Anio, int? Mes);
    }
}
