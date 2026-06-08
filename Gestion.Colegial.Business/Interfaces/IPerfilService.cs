using Gestion.Colegial.Entities;
using System.Threading.Tasks;

namespace Gestion.Colegial.Business.Interfaces
{
    public interface IPerfilService
    {
        Task<Answer> Find(int usuId);
    }
}
