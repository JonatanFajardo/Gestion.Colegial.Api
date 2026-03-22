using Gestion.Colegial.Entities;
using Gestion.Colegial.Entities.Entities;
using System.Collections.Generic;
using System.Threading.Tasks;

namespace Gestion.Colegial.DataAccess.Interfaces
{
    public interface IRolesRepository
    {
        Task<Answer> List();
        Task<Answer> Find(int id);
        Task<Answer> Detail(int id);
        Task<Answer> Create(tbRoles obj);
        Task<Answer> Edit(tbRoles obj);
        Task<Answer> Exist(string value);
        Task<Answer> Delete(int id);
        Task<Answer> PantallasList();
        Task<Answer> PantallasByRol(int rolId);
        Task<Answer> DeletePantallasByRol(int rolId);
        Task<Answer> InsertPantalla(int rolId, int panId);
    }
}
