using Gestion.Colegial.Entities;
using System.Threading.Tasks;

namespace Gestion.Colegial.DataAccess.Interfaces
{
    public interface IRendimientoPorSeccionRepository
    {
        Task<Answer> List(int Anio, int? Par_Id);
    }
}
