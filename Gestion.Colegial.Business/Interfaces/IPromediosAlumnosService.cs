using Gestion.Colegial.Entities;
using System.Threading.Tasks;

namespace Gestion.Colegial.Business.Interfaces
{
    public interface IPromediosAlumnosService
    {
        Task<Answer> List(int Anio, int UmbralBajo);
    }
}
