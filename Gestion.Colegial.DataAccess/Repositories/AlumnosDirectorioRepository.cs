using Gestion.Colegial.DataAccess.Interfaces;
using Gestion.Colegial.Entities;
using Gestion.Colegial.Entities.Entities;
using System.Data;
using System.Data.SqlClient;
using System.Threading.Tasks;

namespace Gestion.Colegial.DataAccess.Repositories
{
    public class AlumnosDirectorioRepository : RepositoryBase, IAlumnosDirectorioRepository
    {
        public async Task<Answer> List(int? Cur_Id, int? Sec_Id)
        {
            const string sql = "app.PR_Alumnos_Directorio";
            SqlParameter[] parameters =
            {
                new SqlParameter { ParameterName = "@Cur_Id", DbType = DbType.Int32, Value = (object)Cur_Id ?? System.DBNull.Value },
                new SqlParameter { ParameterName = "@Sec_Id", DbType = DbType.Int32, Value = (object)Sec_Id ?? System.DBNull.Value },
            };
            return await SearchAll<PR_Alumnos_DirectorioResult>(sql, parameters);
        }
    }
}
