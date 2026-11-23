namespace Gestion.Colegial.Api.Seguridad
{
    /// <summary>Dato del usuario firmado que la API pone en un campo.</summary>
    public enum DatoUsuario
    {
        Usuario,
        Empleado,
        Rol
    }

    /// <summary>
    /// Regla que aplica <see cref="ReglasServidorFilter"/> antes de la acción, solo con GC_API_KEY configurada.
    /// "Campos" son nombres de parámetros de la acción o de propiedades del cuerpo (sin distinguir mayúsculas).
    /// Las pantallas van separadas por "|" y basta con tener una (el admin las tiene todas).
    /// </summary>
    [AttributeUsage(AttributeTargets.Class | AttributeTargets.Method, AllowMultiple = true)]
    public abstract class ReglaServidorAttribute : Attribute
    {
        protected ReglaServidorAttribute(string? pantallas, string[] campos)
        {
            Pantallas = (pantallas ?? "").Split('|', StringSplitOptions.RemoveEmptyEntries | StringSplitOptions.TrimEntries);
            Campos = campos;
        }

        public IReadOnlyList<string> Pantallas { get; }
        public IReadOnlyList<string> Campos { get; }
    }

    /// <summary>El campo lo llena la API con el usuario firmado; lo que mande el ADM se ignora.</summary>
    public sealed class DatoDelServidorAttribute : ReglaServidorAttribute
    {
        public DatoDelServidorAttribute(DatoUsuario dato, params string[] campos) : base(null, campos)
        {
            Dato = dato;
        }

        public DatoUsuario Dato { get; }
    }

    /// <summary>Bandera de permiso: queda en true solo si vino en true y el usuario tiene alguna de las pantallas.</summary>
    public sealed class PermisoDelServidorAttribute : ReglaServidorAttribute
    {
        public PermisoDelServidorAttribute(string pantallas, params string[] campos) : base(pantallas, campos) { }
    }

    /// <summary>
    /// Filtro por empleado: con alguna de las pantallas se respeta lo pedido (null = todos);
    /// sin ellas, solo lo del propio empleado (-1 si el usuario no tiene empleado).
    /// </summary>
    public sealed class AlcanceEmpleadoAttribute : ReglaServidorAttribute
    {
        public AlcanceEmpleadoAttribute(string pantallas, params string[] campos) : base(pantallas, campos) { }
    }

    /// <summary>La acción exige un usuario firmado con alguna de las pantallas (403 si no la tiene).</summary>
    public sealed class RequierePantallaAttribute : ReglaServidorAttribute
    {
        public RequierePantallaAttribute(string pantallas) : base(pantallas, Array.Empty<string>()) { }
    }
}
