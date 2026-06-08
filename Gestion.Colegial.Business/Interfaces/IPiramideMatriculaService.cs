using Gestion.Colegial.Entities;
using System.Threading.Tasks;

namespace Gestion.Colegial.Business.Interfaces
{
    public interface IPiramideMatriculaService
    {
        Task<Answer> List(int Anio);
    }
}
