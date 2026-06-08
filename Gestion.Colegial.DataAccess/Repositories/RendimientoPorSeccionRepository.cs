using Gestion.Colegial.DataAccess.Interfaces;
using Gestion.Colegial.Entities;
using Gestion.Colegial.Entities.Entities;
using System.Data;
using System.Data.SqlClient;
using System.Threading.Tasks;

namespace Gestion.Colegial.DataAccess.Repositories
{
    public class RendimientoPorSeccionRepository : RepositoryBase, IRendimientoPorSeccionRepository
    {
        public async Task<Answer> List(int Anio, int? Par_Id)
        {
            const string sql = "app.PR_Academico_RendimientoPorSeccion";
            SqlParameter[] parameters =
            {
                new SqlParameter { ParameterName = "@Anio",   DbType = DbType.Int32, Value = Anio },
                new SqlParameter { ParameterName = "@Par_Id", DbType = DbType.Int32, Value = (object)Par_Id ?? System.DBNull.Value },
            };
            return await SearchAll<RendimientoPorSeccionResult>(sql, parameters);
        }
    }
}
