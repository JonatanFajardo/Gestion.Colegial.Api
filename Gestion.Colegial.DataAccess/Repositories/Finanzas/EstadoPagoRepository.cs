using Gestion.Colegial.DataAccess.Interfaces.Finanzas;
using Gestion.Colegial.Entities;
using Gestion.Colegial.Entities.Entities;
using System.Data;
using System.Data.SqlClient;

namespace Gestion.Colegial.DataAccess.Repositories.Finanzas
{
    public class EstadoPagoRepository : RepositoryBase, IEstadoPagoRepository
    {
        public async Task<Answer> List()
        {
            const string sql = "finanza.PR_tbEstadosPago_List";
            Answer answer = await Read<PR_tbEstadosPago_ListResult>(sql);
            return answer;
        }

        public async Task<Answer> Find(int id)
        {
            const string sql = "finanza.PR_tbEstadosPago_Find";
            SqlParameter[] sqlParameters = {
                new SqlParameter(){ParameterName= "@Epa_Id", DbType = DbType.Int32, Value = id },
            };
            Answer answer = await Search<PR_tbEstadosPago_FindResult>(sql, sqlParameters);
            return answer;
        }

        public async Task<Answer> Dropdown()
        {
            const string sql = "finanza.PR_tbEstadosPago_Dropdown";
            Answer answer = await Read<PR_tbEstadosPago_DropdownResult>(sql);
            return answer;
        }
    }
}
