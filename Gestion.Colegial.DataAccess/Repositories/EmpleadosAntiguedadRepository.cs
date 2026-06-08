using Gestion.Colegial.DataAccess.Interfaces;
using Gestion.Colegial.Entities;
using Gestion.Colegial.Entities.Entities;
using System.Data;
using System.Data.SqlClient;
using System.Threading.Tasks;

namespace Gestion.Colegial.DataAccess.Repositories
{
    public class EmpleadosAntiguedadRepository : RepositoryBase, IEmpleadosAntiguedadRepository
    {
        public async Task<Answer> List()
        {
            const string sql = "app.PR_Empleados_Antiguedad";
            return await Read<EmpleadosAntiguedadResult>(sql);
        }
    }
}
