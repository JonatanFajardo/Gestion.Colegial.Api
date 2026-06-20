using Gestion.Colegial.DataAccess.Extension;
using Gestion.Colegial.DataAccess.Interfaces;
using Gestion.Colegial.DataAccess.Models.Graduacion;
using Gestion.Colegial.Entities;
using Serilog;
using System.Data;
using System.Data.SqlClient;

namespace Gestion.Colegial.DataAccess.Repositories
{
    /// <summary>
    /// Repositorio del modulo de graduacion. Consume la vista app.vCandidatosGraduacion
    /// y los SPs app.spGraduarAlumno / app.spBackfillGraduadosHistoricos.
    /// </summary>
    /// <remarks>
    /// El SP app.spGraduarAlumno lanza RAISERROR cuando una validacion falla
    /// (deuda pendiente, notas no aprobadas, etc). En esos casos devolvemos
    /// el Answer con Access=true y Message = mensaje del SP para que el controller
    /// devuelva 400 BadRequest sin estallar como 500.
    /// </remarks>
    public class GraduacionRepository : RepositoryBase, IGraduacionRepository
    {
        public async Task<Answer> ListCandidatos()
        {
            const string sql = "SELECT Alu_Id, NombreCompleto, Niv_Descripcion, Cur_Descripcion, " +
                               "Sec_Descripcion, NotasOk, DeudaPendiente, DeudaOk, " +
                               "EstadoValidacion, MotivosBloqueo " +
                               "FROM app.vCandidatosGraduacion";
            Answer answer = new Answer();
            try
            {
                using (SqlConnection connection = new SqlConnection(Connection.GetConnectionString()))
                using (SqlCommand command = new SqlCommand(sql, connection))
                {
                    command.CommandType = CommandType.Text;
                    connection.Open();
                    using (SqlDataReader reader = await command.ExecuteReaderAsync())
                    {
                        DataTable table = new DataTable();
                        table.Load(reader);
                        answer.Data = Mapear.Convert.ToList<CandidatoGraduacionViewModel>(table);
                        if (answer.Data == null) { answer.Access = true; return answer; }
                        answer.Access = false;
                        return answer;
                    }
                }
            }
            catch (Exception e)
            {
                Log.Error(e, "Error consultando app.vCandidatosGraduacion");
                answer.Access = true;
                answer.Incidents(e);
                return answer;
            }
        }

        public async Task<Answer> GraduarAlumno(int aluId, int usuarioId)
        {
            const string sql = "app.spGraduarAlumno";
            Answer answer = new Answer();
            try
            {
                using (SqlConnection con = new SqlConnection(Connection.GetConnectionString()))
                using (SqlCommand command = new SqlCommand(sql, con))
                {
                    command.CommandType = CommandType.StoredProcedure;
                    command.Parameters.Add(new SqlParameter("@Alu_Id", SqlDbType.Int) { Value = aluId });
                    command.Parameters.Add(new SqlParameter("@UsuarioId", SqlDbType.Int) { Value = usuarioId });
                    con.Open();
                    await command.ExecuteNonQueryAsync();
                    answer.Access = false;
                    answer.Message = "Alumno graduado correctamente.";
                    return answer;
                }
            }
            catch (SqlException ex)
            {
                // RAISERROR del SP (validaciones de negocio) — propagamos mensaje al cliente.
                Log.Warning(ex, "Validacion fallida en app.spGraduarAlumno. Alu_Id={AluId}", aluId);
                answer.Access = true;
                answer.Message = ex.Message;
                answer.ErrorDetails = ex.Message;
                return answer;
            }
            catch (Exception e)
            {
                Log.Error(e, "Error general en GraduarAlumno. Alu_Id={AluId}", aluId);
                answer.Access = true;
                answer.Incidents(e);
                return answer;
            }
        }

        public async Task<Answer> Backfill(int? anio, int topN, bool dryRun)
        {
            const string sql = "app.spBackfillGraduadosHistoricos";
            Answer answer = new Answer();
            try
            {
                using (SqlConnection con = new SqlConnection(Connection.GetConnectionString()))
                using (SqlCommand command = new SqlCommand(sql, con))
                {
                    command.CommandType = CommandType.StoredProcedure;
                    command.Parameters.Add(new SqlParameter("@Anio", SqlDbType.Int)
                    {
                        Value = anio.HasValue ? (object)anio.Value : DBNull.Value
                    });
                    command.Parameters.Add(new SqlParameter("@TopN", SqlDbType.Int) { Value = topN });
                    command.Parameters.Add(new SqlParameter("@DryRun", SqlDbType.Bit) { Value = dryRun });

                    con.Open();
                    using (SqlDataReader reader = await command.ExecuteReaderAsync())
                    {
                        DataTable table = new DataTable();
                        table.Load(reader);
                        var detalle = Mapear.Convert.ToList<BackfillDetalleViewModel>(table)
                                       ?? new List<BackfillDetalleViewModel>();

                        var result = new BackfillResultViewModel
                        {
                            DryRun = dryRun,
                            Anio = anio,
                            TopN = topN,
                            Total = detalle.Count,
                            Exitosos = detalle.Count(d => string.Equals(d.Resultado, "OK", StringComparison.OrdinalIgnoreCase)
                                                       || string.Equals(d.Resultado, "Exitoso", StringComparison.OrdinalIgnoreCase)),
                            Fallidos = detalle.Count(d => !string.IsNullOrWhiteSpace(d.Resultado)
                                                       && !d.Resultado!.Equals("OK", StringComparison.OrdinalIgnoreCase)
                                                       && !d.Resultado!.Equals("Exitoso", StringComparison.OrdinalIgnoreCase)),
                            Detalle = detalle
                        };

                        answer.Data = result;
                        answer.Access = false;
                        return answer;
                    }
                }
            }
            catch (SqlException ex)
            {
                Log.Warning(ex, "RAISERROR en app.spBackfillGraduadosHistoricos");
                answer.Access = true;
                answer.Message = ex.Message;
                return answer;
            }
            catch (Exception e)
            {
                Log.Error(e, "Error general en Backfill");
                answer.Access = true;
                answer.Incidents(e);
                return answer;
            }
        }

        public async Task<Answer> ListGraduados()
        {
            const string sql = "SELECT AluGrad_Id, AluGrad_Identidad, AluGrad_NombreCompleto, " +
                               "AluGrad_FechaNacimiento, AluGrad_Sexo, AluGrad_Correo, AluGrad_Telefono, " +
                               "AluGrad_NivelEducativo, AluGrad_TituloObtenido, AluGrad_AnioIngreso, " +
                               "AluGrad_AnioGraduacion, AluGrad_TotalPagado, AluGrad_EncargadosJson, " +
                               "AluGrad_AluIdOriginal, AluGrad_FechaArchivo, AluGrad_UsuarioArchivo " +
                               "FROM app.tbAlumnosGraduados ORDER BY AluGrad_AnioGraduacion DESC, AluGrad_NombreCompleto ASC";
            Answer answer = new Answer();
            try
            {
                using (SqlConnection connection = new SqlConnection(Connection.GetConnectionString()))
                using (SqlCommand command = new SqlCommand(sql, connection))
                {
                    command.CommandType = CommandType.Text;
                    connection.Open();
                    using (SqlDataReader reader = await command.ExecuteReaderAsync())
                    {
                        DataTable table = new DataTable();
                        table.Load(reader);
                        answer.Data = Mapear.Convert.ToList<AlumnoGraduadoViewModel>(table);
                        if (answer.Data == null) { answer.Access = true; return answer; }
                        answer.Access = false;
                        return answer;
                    }
                }
            }
            catch (Exception e)
            {
                Log.Error(e, "Error consultando app.tbAlumnosGraduados");
                answer.Access = true;
                answer.Incidents(e);
                return answer;
            }
        }

        public async Task<Answer> FindGraduado(int aluGradId)
        {
            const string sql = "SELECT AluGrad_Id, AluGrad_Identidad, AluGrad_NombreCompleto, " +
                               "AluGrad_FechaNacimiento, AluGrad_Sexo, AluGrad_Correo, AluGrad_Telefono, " +
                               "AluGrad_NivelEducativo, AluGrad_TituloObtenido, AluGrad_AnioIngreso, " +
                               "AluGrad_AnioGraduacion, AluGrad_TotalPagado, AluGrad_EncargadosJson, " +
                               "AluGrad_AluIdOriginal, AluGrad_FechaArchivo, AluGrad_UsuarioArchivo " +
                               "FROM app.tbAlumnosGraduados WHERE AluGrad_Id = @AluGrad_Id";
            Answer answer = new Answer();
            try
            {
                using (SqlConnection connection = new SqlConnection(Connection.GetConnectionString()))
                using (SqlCommand command = new SqlCommand(sql, connection))
                {
                    command.CommandType = CommandType.Text;
                    command.Parameters.Add(new SqlParameter("@AluGrad_Id", SqlDbType.Int) { Value = aluGradId });
                    connection.Open();
                    using (SqlDataReader reader = await command.ExecuteReaderAsync())
                    {
                        DataTable table = new DataTable();
                        table.Load(reader);
                        var list = Mapear.Convert.ToList<AlumnoGraduadoViewModel>(table);
                        answer.Data = list?.FirstOrDefault();
                        if (answer.Data == null) { answer.Access = true; return answer; }
                        answer.Access = false;
                        return answer;
                    }
                }
            }
            catch (Exception e)
            {
                Log.Error(e, "Error buscando graduado {Id}", aluGradId);
                answer.Access = true;
                answer.Incidents(e);
                return answer;
            }
        }
    }
}
