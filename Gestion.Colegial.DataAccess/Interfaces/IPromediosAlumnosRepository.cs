using Gestion.Colegial.Entities;
using System.Threading.Tasks;

namespace Gestion.Colegial.DataAccess.Interfaces
{
    public interface IPromediosAlumnosRepository
    {
        Task<Answer> List(int Anio, int UmbralBajo);
    }
}
