using Gestion.Colegial.Entities;
using System.Threading.Tasks;

namespace Gestion.Colegial.DataAccess.Interfaces
{
    public interface IFicha360AlumnoRepository
    {
        Task<Answer> Resumen(int Alu_Id);
    }
}
