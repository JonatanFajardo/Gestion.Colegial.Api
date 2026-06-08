using Gestion.Colegial.DataAccess.Interfaces;
using Gestion.Colegial.Entities;
using Gestion.Colegial.Entities.Entities;
using System.Data;
using System.Data.SqlClient;
using System.Threading.Tasks;

namespace Gestion.Colegial.DataAccess.Repositories
{
    public class CumplimientoDocumentosRepository : RepositoryBase, ICumplimientoDocumentosRepository
    {
        public async Task<Answer> List(int? Emp_Id)
        {
            const string sql = "app.PR_Empleados_CumplimientoDocumentos";
            SqlParameter[] parameters =
            {
                new SqlParameter { ParameterName = "@Emp_Id", DbType = DbType.Int32, Value = (object)Emp_Id ?? System.DBNull.Value },
            };
            return await SearchAll<CumplimientoDocumentosResult>(sql, parameters);
        }
    }
}
