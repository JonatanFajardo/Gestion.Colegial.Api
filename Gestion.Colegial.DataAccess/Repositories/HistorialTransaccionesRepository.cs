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
    public class HistorialTransaccionesRepository : RepositoryBase, IHistorialTransaccionesRepository
    {
        public async Task<Answer> List(int? Alu_Id, DateTime? FechaDesde, DateTime? FechaHasta)
        {
            Answer answer = new Answer();
            try
            {
                const string sql = "finanza.PR_Finanza_HistorialTransacciones";
                using SqlConnection connection = new SqlConnection(Connection.GetConnectionString());
                using SqlCommand command = new SqlCommand(sql, connection) { CommandType = CommandType.StoredProcedure };
                command.Parameters.Add(new SqlParameter { ParameterName = "@Alu_Id",     DbType = DbType.Int32, Value = (object)Alu_Id     ?? DBNull.Value });
                command.Parameters.Add(new SqlParameter { ParameterName = "@FechaDesde", DbType = DbType.Date,  Value = (object)FechaDesde ?? DBNull.Value });
                command.Parameters.Add(new SqlParameter { ParameterName = "@FechaHasta", DbType = DbType.Date,  Value = (object)FechaHasta ?? DBNull.Value });

                connection.Open();
                using SqlDataReader reader = await command.ExecuteReaderAsync();
                reader.NextResult(); // el SP retorna 2 result sets: 1ro paginación, 2do detalle
                DataTable table = new DataTable();
                table.Load(reader);
                answer.Data = Mapear.Convert.ToList<PR_Finanza_HistorialTransaccionesResult>(table);
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
