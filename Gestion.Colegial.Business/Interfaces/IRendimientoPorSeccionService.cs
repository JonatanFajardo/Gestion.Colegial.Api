using Gestion.Colegial.Entities;
using System.Threading.Tasks;

namespace Gestion.Colegial.Business.Interfaces
{
    public interface IRendimientoPorSeccionService
    {
        Task<Answer> List(int Anio, int? Par_Id);
    }
}
