namespace Gestion.Colegial.DataAccess
{
    public class Connection
    {
        /// <summary>
        /// Obtiene la cadena de conexión.
        /// </summary>
        /// <returns>Retorna la cadena de conexión.</returns>
        public static string GetConnectionString()
        {
            // Permite sobrescribir la conexión por variable de entorno (p. ej. en Docker,
            // apuntando al contenedor de SQL Server con autenticación SQL).
            var fromEnv = Environment.GetEnvironmentVariable("GESTIONCOLEGIAL_CONNECTION");
            if (!string.IsNullOrWhiteSpace(fromEnv))
                return fromEnv;

            // Fallback: desarrollo local con LocalDB (comportamiento original, sin cambios).
            string connection = "Data Source=(localdb)\\MSSQLLocalDB;Initial Catalog=DB_GestionColegial;Integrated Security=True;Encrypt=False";
            return connection;
        }
    }
}
