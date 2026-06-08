using Gestion.Colegial.Entities;
using System.Threading.Tasks;

namespace Gestion.Colegial.Business.Interfaces
{
    public interface IBoletinService
    {
        Task<Answer> Generate(int Alu_Id, int Anio);
    }
}
