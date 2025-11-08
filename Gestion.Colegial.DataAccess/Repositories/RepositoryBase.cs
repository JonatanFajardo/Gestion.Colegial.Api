using Gestion.Colegial.DataAccess.Extension;
using Gestion.Colegial.Entities;
using System.Data;
using System.Data.SqlClient;

namespace Gestion.Colegial.DataAccess.Repositories
{
    public class RepositoryBase
    {
        /// <summary>
        /// Crea una petición a la base de datos para obtener registros dados por el procedimiento.
        /// </summary>
        /// <typeparam name="T"></typeparam>
        /// <param name="queryString"></param>
        /// <returns></returns>
        public async Task<Answer> Read<T>(string queryString)
        {
            Answer answer = new Answer();
            try
            {
                using (SqlConnection connection = new SqlConnection(Connection.GetConnectionString()))
                {
                    using (SqlCommand command = new SqlCommand(queryString, connection))
                    {
                        connection.Open();
                        SqlDataReader reader = await command.ExecuteReaderAsync();
                        DataTable table = new DataTable();
                        table.Load(reader);
                        answer.Data = Mapear.Convert.ToList<T>(table);
                        if (answer.Data == null)
                        {
                            answer.Access = true;
                            return answer;
                        }
                        connection.Close();
                        answer.Access = false;
                        return answer;
                    }
                }
            }
            catch (SqlException ex)
            {
                answer.Access = true;
                answer.Incidents(ex); answer.Data = "";
                return answer;
            }
            catch (Exception e)
            {
                answer.Access = true;
                answer.Incidents(e);
                answer.Data = "";
                return answer;
            }
        }

        /// <summary>
        /// Crea una petición a la base de datos para obtener registros dados por el procedimiento.
        /// </summary>
        /// <remarks>
        /// Util para obtener los datos de un dropdown en cascada.
        /// </remarks>
        /// <typeparam name="T"></typeparam>
        /// <param name="queryString"></param>
        /// <returns></returns>
        public async Task<Answer> Read<T>(string queryString, dynamic parameters)
        {
            Answer answer = new Answer();
            try
            {
                using (SqlConnection connection = new SqlConnection(Connection.GetConnectionString()))
                {
                    using (SqlCommand command = new SqlCommand(queryString, connection))
                    {
                        command.CommandType = CommandType.StoredProcedure;
                        command.Parameters.AddRange(parameters);

                        connection.Open();
                        SqlDataReader reader = await command.ExecuteReaderAsync();
                        DataTable table = new DataTable();
                        table.Load(reader);
                        answer.Data = Mapear.Convert.ToList<T>(table);
                        if (answer.Data == null)
                        {
                            answer.Access = true;
                            return answer;
                        }
                        connection.Close();
                        answer.Access = false;
                        return answer;
                    }
                }
            }
            catch (Exception e)
            {
                answer.Access = true;
                answer.Incidents(e);
                answer.Data = "";
                return answer;
            }
        }

        /// <summary>
        /// Crea una petición a la base de datos para obtener un registro especifico.
        /// </summary>
        /// <typeparam name="T"></typeparam>
        /// <param name="queryString"></param>
        /// <param name="parameters"></param>
        /// <param name="id"></param>
        /// <returns></returns>
        public async Task<Answer> Search<T>(string queryString, dynamic parameters)
        {
            Answer answer = new Answer();
            try
            {
                using (SqlConnection connection = new SqlConnection(Connection.GetConnectionString()))
                {
                    using (SqlCommand command = new SqlCommand(queryString, connection))
                    {
                        command.CommandType = CommandType.StoredProcedure;
                        command.Parameters.AddRange(parameters);

                        connection.Open();
                        SqlDataReader reader = await command.ExecuteReaderAsync();
                        DataTable table = new DataTable();
                        table.Load(reader);
                        answer.Data = Mapear.Convert.ToList<T>(table).FirstOrDefault();
                        if (answer.Data == null)
                        {
                            answer.Access = true;
                            return answer;
                        }
                        answer.Access = false;
                        connection.Close();
                        return answer;
                    }
                }
            }
            catch (Exception e)
            {
                answer.Access = true;
                answer.Incidents(e);
                answer.Data = "";
                return answer;
            }
        }

        public async Task<Answer> SearchAll<T>(string queryString, dynamic parameters)
        {
            Answer answer = new Answer();
            try
            {
                using (SqlConnection connection = new SqlConnection(Connection.GetConnectionString()))
                {
                    using (SqlCommand command = new SqlCommand(queryString, connection))
                    {
                        command.CommandType = CommandType.StoredProcedure;
                        command.Parameters.AddRange(parameters);

                        connection.Open();
                        SqlDataReader reader = await command.ExecuteReaderAsync();
                        DataTable table = new DataTable();
                        table.Load(reader);
                        answer.Data = Mapear.Convert.ToList<T>(table);
                        if (answer.Data == null)
                        {
                            answer.Access = true;
                            return answer;
                        }
                        connection.Close();
                        answer.Access = false;
                        return answer;
                    }
                }
            }
            catch (Exception e)
            {
                answer.Access = true;
                answer.Incidents(e);
                answer.Data = "";
                return answer;
            }
        }

        /// <summary>
        /// Crea una petición a la base de datos para obtener los detalles de un registro.
        /// </summary>
        /// <typeparam name="T"></typeparam>
        /// <param name="queryString"></param>
        /// <param name="parameters"></param>
        /// <param name="id"></param>
        /// <returns></returns>
        public async Task<Answer> Details<T>(string queryString, dynamic parameters, int id)
        {
            Answer answer = new Answer();
            try
            {
                using (SqlConnection connection = new SqlConnection(Connection.GetConnectionString()))
                {
                    using (SqlCommand command = new SqlCommand(queryString, connection))
                    {
                        command.CommandType = CommandType.StoredProcedure;
                        command.Parameters.AddRange(parameters);

                        connection.Open();
                        SqlDataReader reader = await command.ExecuteReaderAsync();
                        DataTable table = new DataTable();
                        table.Load(reader);
                        answer.Data = Mapear.Convert.ToList<T>(table).FirstOrDefault();
                        if (answer.Data == null)
                        {
                            answer.Access = true;
                            return answer;
                        }
                        answer.Access = false;
                        connection.Close();
                        return answer;
                    }
                }
            }
            catch (Exception e)
            {
                answer.Access = true;
                answer.Incidents(e);
                answer.Data = "";
                return answer;
            }
        }

        /// <summary>
        /// Crea una petición a la base de datos para ingresar un nuevo registro.
        /// </summary>
        /// <param name="queryString"></param>
        /// <param name="parameters"></param>
        /// <returns></returns>
        public async Task<Answer> New(string queryString, dynamic parameters)
        {
            Answer answer = new Answer();
            try
            {
                using (SqlConnection con = new SqlConnection(Connection.GetConnectionString()))
                {
                    using (SqlCommand command = new SqlCommand(queryString, con))
                    {
                        command.CommandType = CommandType.StoredProcedure;
                        command.Parameters.AddRange(parameters);

                        con.Open();
                        int result = await command.ExecuteNonQueryAsync();
                        if (result < 1)
                        {
                            answer.Message = "Ninguna fila Registrada";
                            answer.Access = true;
                            return answer;
                        }
                        answer.Access = false;
                        return answer;
                    }
                }
            }
            catch (Exception error)
            {
                answer.Incidents(error);
                answer.Access = true;
                return answer;
            }
        }

        /// <summary>
        /// Crea una petición a la base de datos para actualizar un registro.
        /// </summary>
        /// <param name="queryString"></param>
        /// <param name="parameters"></param>
        /// <returns></returns>
        public async Task<Answer> Update(string queryString, dynamic parameters)
        {
            Answer answer = new Answer();
            try
            {
                using (SqlConnection con = new SqlConnection(Connection.GetConnectionString()))
                {
                    using (SqlCommand command = new SqlCommand(queryString, con))
                    {
                        command.CommandType = CommandType.StoredProcedure;
                        command.Parameters.AddRange(parameters);

                        con.Open();
                        int result = await command.ExecuteNonQueryAsync();
                        if (result < 1)
                        {
                            answer.Message = "Ninguna fila Registrada";
                            answer.Access = true;
                            return answer;
                        }
                        answer.Access = false;
                        return answer;
                    }
                }
            }
            catch (Exception error)
            {
                answer.Incidents(error);
                answer.Access = true;
                return answer;
            }
        }

        /// <summary>
        /// Crea una petición a la base de datos para obtener un registro especifico.
        /// </summary>
        /// <typeparam name="T"></typeparam>
        /// <param name="queryString"></param>
        /// <param name="parameters"></param>
        /// <returns></returns>
        public async Task<Answer> Exist<T>(string queryString, dynamic parameters)
        {
            Answer answer = new Answer();
            try
            {
                using (SqlConnection connection = new SqlConnection(Connection.GetConnectionString()))
                {
                    using (SqlCommand command = new SqlCommand(queryString, connection))
                    {
                        command.CommandType = CommandType.StoredProcedure;
                        command.Parameters.AddRange(parameters);

                        connection.Open();
                        SqlDataReader reader = await command.ExecuteReaderAsync();
                        DataTable table = new DataTable();
                        table.Load(reader);
                        answer.Data = Mapear.Convert.ToList<T>(table).FirstOrDefault();
                        answer.Access = false;
                        connection.Close();
                        return answer;
                    }
                }
            }
            catch (Exception e)
            {
                answer.Access = true;
                answer.Incidents(e);
                answer.Data = "";
                return answer;
            }
        }

        /// <summary>
        /// Crea una petición a la base de datos para eliminar un registro.
        /// </summary>
        /// <param name="queryString"></param>
        /// <param name="parameters"></param>
        /// <returns></returns>
        public async Task<Answer> Delete(string queryString, dynamic parameters)
        {
            Answer answer = new Answer();
            try
            {
                using (SqlConnection con = new SqlConnection(Connection.GetConnectionString()))
                {
                    using (SqlCommand command = new SqlCommand(queryString, con))
                    {
                        command.CommandType = CommandType.StoredProcedure;
                        command.Parameters.AddRange(parameters);

                        con.Open();
                        int result = await command.ExecuteNonQueryAsync();
                        if (result < 1)
                        {
                            answer.Message = "Ninguna fila afectada";
                            answer.Access = true;
                            return answer;
                        }
                        answer.Access = false;
                        return answer;
                    }
                }
            }
            catch (Exception error)
            {
                answer.Access = true;
                answer.Incidents(error);
                return answer;
            }
        }

        /// <summary>
        /// Envia multiples peticiones de inserción a la base de datos.
        /// </summary>
        /// <param name="queryString"></param>
        /// <param name="parameters"></param>
        /// <returns></returns>
    }
}