using Gestion.Colegial.DataAccess.Interfaces;
using Gestion.Colegial.Entities;
using Gestion.Colegial.Entities.Entities;
using Serilog;
using System.Data;
using System.Data.SqlClient;
using System.Threading.Tasks;

namespace Gestion.Colegial.DataAccess.Repositories
{
    public class ConfiguracionRepository : RepositoryBase, IConfiguracionRepository
    {
        public async Task<Answer> List()
        {
            const string sql = "app.PR_Configuracion_List";
            return await SearchAll<PR_Configuracion_ListResult>(sql, new SqlParameter[0]);
        }

        public async Task<Answer> Update(int Con_Id, string Con_Valor, int UsuarioModifica)
        {
            const string sql = "app.PR_Configuracion_Update";
            SqlParameter[] parameters =
            {
                new SqlParameter { ParameterName = "@Con_Id",          DbType = DbType.Int32,  Value = Con_Id },
                new SqlParameter { ParameterName = "@Con_Valor",       DbType = DbType.String, Value = (object)Con_Valor ?? System.DBNull.Value },
                new SqlParameter { ParameterName = "@UsuarioModifica", DbType = DbType.Int32,  Value = UsuarioModifica },
            };
            return await Update(sql, parameters);
        }

        /// <summary>
        /// Lee un par clave/valor de app.tbConfiguracion. Devuelve un objeto { Clave, Valor }
        /// para que el cliente (MVC) lo mapee a ConfiguracionValorViewModel.
        /// </summary>
        public async Task<Answer> GetValorPorClave(string clave)
        {
            const string sql = "SELECT TOP 1 Con_Clave AS Clave, Con_Valor AS Valor " +
                               "FROM app.tbConfiguracion WHERE Con_Clave = @Clave";
            Answer answer = new Answer();
            try
            {
                using (SqlConnection connection = new SqlConnection(Connection.GetConnectionString()))
                using (SqlCommand command = new SqlCommand(sql, connection))
                {
                    command.CommandType = CommandType.Text;
                    command.Parameters.Add(new SqlParameter("@Clave", SqlDbType.NVarChar, 100) { Value = clave });
                    connection.Open();
                    using (SqlDataReader reader = await command.ExecuteReaderAsync())
                    {
                        if (await reader.ReadAsync())
                        {
                            answer.Data = new
                            {
                                Clave = reader["Clave"]?.ToString(),
                                Valor = reader["Valor"]?.ToString()
                            };
                            answer.Access = false;
                            return answer;
                        }
                        // Si no existe la clave, devolvemos vacío sin marcar como error.
                        answer.Data = new { Clave = clave, Valor = (string?)null };
                        answer.Access = false;
                        return answer;
                    }
                }
            }
            catch (Exception e)
            {
                Log.Error(e, "Error en GetValorPorClave. Clave={Clave}", clave);
                answer.Access = true;
                answer.Incidents(e);
                return answer;
            }
        }

        /// <summary>
        /// UPSERT por Con_Clave (que tiene UNIQUE constraint).
        /// Si existe la clave actualiza Con_Valor / UsuarioModifica / FechaModifica;
        /// si no existe la inserta. Mantiene compatibilidad con el resto de columnas opcionales.
        /// </summary>
        public async Task<Answer> SetValorPorClave(string clave, string valor, int usuarioId)
        {
            const string sql = @"
IF EXISTS (SELECT 1 FROM app.tbConfiguracion WHERE Con_Clave = @Clave)
BEGIN
    UPDATE app.tbConfiguracion
        SET Con_Valor       = @Valor,
            FechaModifica   = GETDATE(),
            UsuarioModifica = @UsuarioId
        WHERE Con_Clave = @Clave;
END
ELSE
BEGIN
    INSERT INTO app.tbConfiguracion (Con_Clave, Con_Valor, FechaModifica, UsuarioModifica)
    VALUES (@Clave, @Valor, GETDATE(), @UsuarioId);
END";
            Answer answer = new Answer();
            try
            {
                using (SqlConnection con = new SqlConnection(Connection.GetConnectionString()))
                using (SqlCommand command = new SqlCommand(sql, con))
                {
                    command.CommandType = CommandType.Text;
                    command.Parameters.Add(new SqlParameter("@Clave", SqlDbType.NVarChar, 100) { Value = clave });
                    command.Parameters.Add(new SqlParameter("@Valor", SqlDbType.NVarChar, 500) { Value = (object?)valor ?? DBNull.Value });
                    command.Parameters.Add(new SqlParameter("@UsuarioId", SqlDbType.Int) { Value = usuarioId });
                    con.Open();
                    await command.ExecuteNonQueryAsync();
                    answer.Access = false;
                    return answer;
                }
            }
            catch (Exception e)
            {
                Log.Error(e, "Error en SetValorPorClave. Clave={Clave}", clave);
                answer.Access = true;
                answer.Incidents(e);
                return answer;
            }
        }
    }
}
