using Gestion.Colegial.DataAccess.Interfaces;
using Gestion.Colegial.Entities;
using Gestion.Colegial.Entities.Entities;
using System.Data;
using System.Data.SqlClient;
using System.Threading.Tasks;

namespace Gestion.Colegial.DataAccess.Repositories
{
    public class BoletinRepository : RepositoryBase, IBoletinRepository
    {
        public async Task<Answer> Generate(int Alu_Id, int Anio)
        {
            const string sql = "app.PR_Boletin_Generate";
            SqlParameter[] parameters =
            {
                new SqlParameter { ParameterName = "@Alu_Id", DbType = DbType.Int32, Value = Alu_Id },
                new SqlParameter { ParameterName = "@Anio",   DbType = DbType.Int32, Value = Anio },
            };
            return await SearchAll<PR_Boletin_GenerateResult>(sql, parameters);
        }
    }
}
