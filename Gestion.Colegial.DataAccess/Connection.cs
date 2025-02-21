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
            string connection = "Data Source=DESKTOP-I0I12OB;Initial Catalog=DB_GestionColegial;User ID=jonna;Password=admin";
            //string connection = Properties.Settings.Default.ConnectionString_GestionColegial_EntitiesDB;
            return connection;
        }
    }
}
