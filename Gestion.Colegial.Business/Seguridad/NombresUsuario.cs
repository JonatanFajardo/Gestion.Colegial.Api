using System.Text.RegularExpressions;

namespace Gestion.Colegial.Business.Seguridad
{
    /// <summary>
    /// Regla del nombre de usuario (la misma al crear y al editar, y la que aplican el ADM y los
    /// procedimientos Seguridad.UDP_tbUsuarios_Insert / _Update): 4 a 50 caracteres, solo letras sin tilde,
    /// números, punto, guion y guion bajo; sin espacios.
    /// </summary>
    public static class NombresUsuario
    {
        public const string Mensaje = "El usuario debe tener entre 4 y 50 caracteres: letras, números, punto, guion o guion bajo, sin espacios.";

        private static readonly Regex Patron = new Regex("^[-a-zA-Z0-9._]{4,50}$", RegexOptions.CultureInvariant);

        /// <summary>Devuelve el motivo si el nombre no sirve; null si es válido.</summary>
        public static string? Validar(string? nombre)
        {
            return nombre != null && Patron.IsMatch(nombre.Trim()) ? null : Mensaje;
        }
    }
}
