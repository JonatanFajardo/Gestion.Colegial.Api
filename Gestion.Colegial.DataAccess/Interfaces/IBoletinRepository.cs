using Gestion.Colegial.Entities;
using System.Threading.Tasks;

namespace Gestion.Colegial.DataAccess.Interfaces
{
    public interface IBoletinRepository
    {
        Task<Answer> Generate(int Alu_Id, int Anio);
    }
}
