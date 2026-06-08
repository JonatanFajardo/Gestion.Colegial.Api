using Gestion.Colegial.Entities;
using System.Threading.Tasks;

namespace Gestion.Colegial.Business.Interfaces
{
    public interface IConfiguracionService
    {
        Task<Answer> List();
        Task<Answer> Update(int Con_Id, string Con_Valor, int UsuarioModifica);
    }
}
