using Gestion.Colegial.Entities;
using Gestion.Colegial.Entities.Entities;
using System.Threading.Tasks;

namespace Gestion.Colegial.DataAccess.Interfaces
{
    public interface IUsuarioRepository
    {
        Task<Answer> LoginAsync(string username, string password);
        Task<Answer> LoginInAsync(int usuId, string userIp);
        Task<Answer> LogoutAsync(int usuId);
        Task<Answer> GetPantallasByRolAsync(int rolId);

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