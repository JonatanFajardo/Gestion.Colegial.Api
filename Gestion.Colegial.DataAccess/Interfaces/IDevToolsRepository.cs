using Gestion.Colegial.Entities;
using System.Threading.Tasks;

namespace Gestion.Colegial.DataAccess.Interfaces
{
    public interface IDevToolsRepository
    {
        Task<Answer> Detectar(int? AnioObjetivo);
        Task<Answer> Paso(string Tabla, int Delta);
        Task<Answer> EstadoBD();
        Task<Answer> ListarRoles();
    }
}
