using Gestion.Colegial.Entities;
using System.Threading.Tasks;

namespace Gestion.Colegial.Business.Interfaces
{
    public interface IDevToolsService
    {
        Task<Answer> Detectar(int? AnioObjetivo);
        Task<Answer> Paso(string Tabla, int Delta);
        Task<Answer> EstadoBD();
        Task<Answer> ListarRoles();
    }
}
