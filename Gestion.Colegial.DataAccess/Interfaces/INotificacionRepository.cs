using Gestion.Colegial.Entities;
using System.Threading.Tasks;

namespace Gestion.Colegial.DataAccess.Interfaces
{
    public interface INotificacionRepository
    {
        Task<Answer> ListByUsuario(int usuId, bool soloNoLeidas);
        Task<Answer> MarcarLeida(int notId);
        Task<Answer> Insert(int usuId, string titulo, string mensaje, string tipo, string urlDestino, int usuarioRegistra);
    }
}
