using Gestion.Colegial.Entities;
using Gestion.Colegial.Entities.DTOs;
using Gestion.Colegial.Entities.Entities;
using System.Threading.Tasks;

namespace Gestion.Colegial.Business.Interfaces
{
    public interface IUsuarioService
    {
        Task<Answer> AuthenticateAsync(LoginRequestDTO loginRequest, string userIp);
        Task<Answer> LogoutAsync(int usuId);
        Task<Answer> EstadoSesionAsync(int usuId);
        Task<Answer> CambiarContrasenaAsync(CambiarContrasenaDTO dto);
        Task<Answer> GuardarContrasenaAsync(int usuId, string usuName, string? nueva, int? actorId, string accion, string? ip);

        // CRUD
        Task<Answer> List();
        Task<Answer> Find(int id);
        Task<Answer> Detail(int id);
        Task<Answer> Create(tbUsuarios obj);
        Task<Answer> Edit(tbUsuarios obj);
        Task<Answer> Exist(string value);
        Task<Answer> Delete(int id);
        Task<Answer> RolesDropdown();
    }
}