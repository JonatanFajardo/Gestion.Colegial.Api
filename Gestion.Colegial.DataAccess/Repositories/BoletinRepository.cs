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
            // Notas del boletín como único result set (ver script 067). PR_Boletin_Generate
            // devolvía 3 result sets y el reader solo leía el primero (datos del alumno).
            const string sql = "app.PR_Boletin_Notas";
            SqlParameter[] parameters =
            {
                new SqlParameter { ParameterName = "@Alu_Id", DbType = DbType.Int32, Value = Alu_Id },
                new SqlParameter { ParameterName = "@Anio",   DbType = DbType.Int32, Value = Anio },
            };
            return await SearchAll<PR_Boletin_GenerateResult>(sql, parameters);
        }
    }
}
