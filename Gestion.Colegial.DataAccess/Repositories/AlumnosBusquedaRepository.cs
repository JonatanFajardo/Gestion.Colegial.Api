using System;
using Gestion.Colegial.DataAccess.Interfaces;
using Gestion.Colegial.Entities;
using Gestion.Colegial.Entities.Entities;
using System.Data;
using System.Data.SqlClient;
using System.Threading.Tasks;

namespace Gestion.Colegial.DataAccess.Repositories
{
    public class AlumnosBusquedaRepository : RepositoryBase, IAlumnosBusquedaRepository
    {
        public async Task<Answer> Search(string Termino)
        {
            const string sql = "app.PR_Alumnos_BusquedaGlobal";
            SqlParameter[] parameters =
            {
                new SqlParameter { ParameterName = "@Termino", DbType = DbType.String, Value = (object)Termino ?? DBNull.Value },
            };
            return await SearchAll<AlumnosBusquedaResult>(sql, parameters);
        }
    }
}
