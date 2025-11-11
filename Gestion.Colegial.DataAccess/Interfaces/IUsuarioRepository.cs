using Gestion.Colegial.Entities;
using System.Threading.Tasks;

namespace Gestion.Colegial.DataAccess.Interfaces
{
    public interface IUsuarioRepository
    {
        Task<Answer> LoginAsync(string username, string password);
        Task<Answer> LoginInAsync(int usuId, string userIp);
        Task<Answer> LogoutAsync(int usuId);
    }
}