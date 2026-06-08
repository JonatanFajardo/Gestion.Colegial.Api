using Gestion.Colegial.Business.Interfaces;
using Gestion.Colegial.DataAccess.Interfaces;
using Gestion.Colegial.Entities;
using System.Threading.Tasks;

namespace Gestion.Colegial.Business.Services
{
    public class DevToolsService : IDevToolsService
    {
        private readonly IDevToolsRepository _repo;
        public DevToolsService(IDevToolsRepository repo) { _repo = repo; }

        public Task<Answer> Detectar(int? AnioObjetivo) => _repo.Detectar(AnioObjetivo);
        public Task<Answer> Paso(string Tabla, int Delta) => _repo.Paso(Tabla, Delta);
        public Task<Answer> EstadoBD() => _repo.EstadoBD();
        public Task<Answer> ListarRoles() => _repo.ListarRoles();
    }
}
