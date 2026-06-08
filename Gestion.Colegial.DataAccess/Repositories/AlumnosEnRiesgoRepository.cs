using System;
using Gestion.Colegial.DataAccess.Interfaces;
using Gestion.Colegial.Entities;
using Gestion.Colegial.Entities.Entities;
using System.Data;
using System.Data.SqlClient;
using System.Threading.Tasks;

namespace Gestion.Colegial.DataAccess.Repositories
{
    public class AlumnosEnRiesgoRepository : RepositoryBase, IAlumnosEnRiesgoRepository
    {
        public async Task<Answer> List(decimal? PromedioMinimo, int? Anio)
        {
            const string sql = "app.PR_Academico_AlumnosEnRiesgo";
            SqlParameter[] parameters =
            {
                new SqlParameter { ParameterName = "@PromedioMinimo", DbType = DbType.Decimal, Value = (object)PromedioMinimo ?? DBNull.Value },
                new SqlParameter { ParameterName = "@Anio", DbType = DbType.Int32, Value = (object)Anio ?? DBNull.Value },
            };
            return await SearchAll<AlumnosEnRiesgoResult>(sql, parameters);
        }
    }
}
