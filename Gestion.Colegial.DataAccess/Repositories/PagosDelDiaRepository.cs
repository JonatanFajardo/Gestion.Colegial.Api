using Gestion.Colegial.DataAccess.Extension;
using Gestion.Colegial.DataAccess.Interfaces;
using Gestion.Colegial.Entities;
using Gestion.Colegial.Entities.Entities;
using System;
using System.Data;
using System.Data.SqlClient;
using System.Threading.Tasks;

namespace Gestion.Colegial.DataAccess.Repositories
{
    public class PagosDelDiaRepository : RepositoryBase, IPagosDelDiaRepository
    {
        public async Task<Answer> List(DateTime Fecha)
        {
            Answer answer = new Answer();
            try
            {
                const string sql = "finanza.PR_Finanza_PagosDelDia";
                using SqlConnection connection = new SqlConnection(Connection.GetConnectionString());
                using SqlCommand command = new SqlCommand(sql, connection) { CommandType = CommandType.StoredProcedure };
                command.Parameters.Add(new SqlParameter { ParameterName = "@Fecha", DbType = DbType.Date, Value = Fecha });

                connection.Open();
                using SqlDataReader reader = await command.ExecuteReaderAsync();
                reader.NextResult(); // el SP retorna 2 result sets: 1ro resumen, 2do detalle
                DataTable table = new DataTable();
                table.Load(reader);
                answer.Data = Mapear.Convert.ToList<PR_Finanza_PagosDelDiaResult>(table);
                answer.Access = false;
                return answer;
            }
            catch (Exception e)
            {
                answer.Access = true;
                answer.Incidents(e);
                return answer;
            }
        }
    }
}
