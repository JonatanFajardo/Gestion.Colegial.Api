using System;
using Gestion.Colegial.DataAccess.Interfaces;
using Gestion.Colegial.Entities;
using Gestion.Colegial.Entities.Entities;
using System.Data;
using System.Data.SqlClient;
using System.Threading.Tasks;

namespace Gestion.Colegial.DataAccess.Repositories
{
    public class MorosidadPorNivelRepository : RepositoryBase, IMorosidadPorNivelRepository
    {
        public async Task<Answer> List(int? Anio)
        {
            const string sql = "finanza.PR_Finanza_Morosidad_PorNivel";
            SqlParameter[] parameters =
            {
                new SqlParameter { ParameterName = "@Anio", DbType = DbType.Int32, Value = (object)Anio ?? DBNull.Value },
            };
            return await SearchAll<MorosidadPorNivelResult>(sql, parameters);
        }
    }
}
