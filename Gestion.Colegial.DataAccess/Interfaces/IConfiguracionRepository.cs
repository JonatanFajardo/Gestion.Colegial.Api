using Gestion.Colegial.Entities;
using System.Threading.Tasks;

namespace Gestion.Colegial.DataAccess.Interfaces
{
    public interface IConfiguracionRepository
    {
        Task<Answer> List();
        Task<Answer> Update(int Con_Id, string Con_Valor, int UsuarioModifica);
        Task<Answer> GetValorPorClave(string clave);
        Task<Answer> SetValorPorClave(string clave, string valor, int usuarioId);
    }
}
