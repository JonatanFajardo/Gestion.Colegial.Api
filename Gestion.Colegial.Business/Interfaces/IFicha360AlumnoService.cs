using Gestion.Colegial.Entities;
using System.Threading.Tasks;

namespace Gestion.Colegial.Business.Interfaces
{
    public interface IFicha360AlumnoService
    {
        Task<Answer> Resumen(int Alu_Id);
    }
}
