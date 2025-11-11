using Gestion.Colegial.Entities;
using Gestion.Colegial.Entities.DTOs;
using System.Threading.Tasks;

namespace Gestion.Colegial.Business.Interfaces
{
    public interface IUsuarioService
    {
        Task<Answer> AuthenticateAsync(LoginRequestDTO loginRequest, string userIp);
        Task<Answer> LogoutAsync(int usuId);
    }
}