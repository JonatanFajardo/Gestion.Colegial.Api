using Gestion.Colegial.DataAccess.Interfaces;
using Gestion.Colegial.Entities;
using Gestion.Colegial.Entities.Entities;
using System.Data;
using System.Data.SqlClient;
using System.Threading.Tasks;

namespace Gestion.Colegial.DataAccess.Repositories
{
    public class MisAlumnosRepository : RepositoryBase, IMisAlumnosRepository
    {
        public async Task<Answer> GetByHorario(int Hor_Id)
        {
            const string sql = "app.PR_Docente_MisAlumnos";
            SqlParameter[] p = { new SqlParameter { ParameterName = "@Hor_Id", DbType = DbType.Int32, Value = Hor_Id } };
            return await SearchAll<PR_Docente_MisAlumnosResult>(sql, p);
        }
    }
}
