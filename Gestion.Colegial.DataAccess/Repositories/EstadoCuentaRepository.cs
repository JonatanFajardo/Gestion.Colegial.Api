using System;
using Gestion.Colegial.DataAccess.Interfaces;
using Gestion.Colegial.Entities;
using Gestion.Colegial.Entities.Entities;
using System.Data;
using System.Data.SqlClient;
using System.Threading.Tasks;

namespace Gestion.Colegial.DataAccess.Repositories
{
    public class EstadoCuentaRepository : RepositoryBase, IEstadoCuentaRepository
    {
        public async Task<Answer> Find(int Alu_Id, int? Anio)
        {
            const string sql = "finanza.PR_Finanza_EstadoCuenta";
            SqlParameter[] parameters =
            {
                new SqlParameter { ParameterName = "@Alu_Id", DbType = DbType.Int32, Value = Alu_Id },
                new SqlParameter { ParameterName = "@Anio", DbType = DbType.Int32, Value = (object)Anio ?? DBNull.Value },
            };
            return await SearchAll<EstadoCuentaResult>(sql, parameters);
        }
    }
}
