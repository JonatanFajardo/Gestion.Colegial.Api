using Gestion.Colegial.DataAccess.Interfaces;
using Gestion.Colegial.Entities;
using Gestion.Colegial.Entities.Entities;
using System.Data;
using System.Data.SqlClient;
using System.Threading.Tasks;

namespace Gestion.Colegial.DataAccess.Repositories
{
    public class PromediosAlumnosRepository : RepositoryBase, IPromediosAlumnosRepository
    {
        public async Task<Answer> List(int Anio, int UmbralBajo)
        {
            const string sql = "app.PR_Academico_PromediosPorAlumno";
            SqlParameter[] parameters =
            {
                new SqlParameter { ParameterName = "@Anio",       DbType = DbType.Int32, Value = Anio },
                new SqlParameter { ParameterName = "@UmbralBajo", DbType = DbType.Int32, Value = UmbralBajo },
            };
            return await SearchAll<PromedioAlumnoResult>(sql, parameters);
        }
    }
}
