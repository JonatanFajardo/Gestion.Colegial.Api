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
            string connection = "Data Source=(localdb)\\MSSQLLocalDB;Initial Catalog=DB_GestionColegial;Integrated Security=True;Encrypt=False";
            //string connection = Properties.Settings.Default.ConnectionString_GestionColegial_EntitiesDB;
            return connection;
        }
    }
}
