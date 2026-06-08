using Gestion.Colegial.DataAccess.Interfaces;
using Gestion.Colegial.Entities;
using Gestion.Colegial.Entities.Entities;
using System.Data;
using System.Data.SqlClient;
using System.Threading.Tasks;

namespace Gestion.Colegial.DataAccess.Repositories
{
    public class PiramideMatriculaRepository : RepositoryBase, IPiramideMatriculaRepository
    {
        public async Task<Answer> List(int Anio)
        {
            const string sql = "app.PR_Alumnos_PiramideMatricula";
            SqlParameter[] parameters =
            {
                new SqlParameter { ParameterName = "@Anio", DbType = DbType.Int32, Value = Anio },
            };
            return await SearchAll<PR_Alumnos_PiramideMatriculaResult>(sql, parameters);
        }
    }
}
