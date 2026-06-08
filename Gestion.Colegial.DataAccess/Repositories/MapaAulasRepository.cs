using Gestion.Colegial.DataAccess.Interfaces;
using Gestion.Colegial.Entities;
using Gestion.Colegial.Entities.Entities;
using System.Threading.Tasks;

namespace Gestion.Colegial.DataAccess.Repositories
{
    public class MapaAulasRepository : RepositoryBase, IMapaAulasRepository
    {
        public async Task<Answer> GetMapa()
        {
            const string sql = "app.PR_Aulas_MapaOcupacion";
            return await Read<PR_Aulas_MapaOcupacionResult>(sql);
        }
    }
}
