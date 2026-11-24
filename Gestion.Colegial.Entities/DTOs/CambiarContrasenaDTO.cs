namespace Gestion.Colegial.Entities.DTOs
{
    /// <summary>Cambio de la propia contraseña. Usu_Id lo pone la API con el usuario firmado.</summary>
    public class CambiarContrasenaDTO
    {
        public int Usu_Id { get; set; }
        public string? ContrasenaActual { get; set; }
        public string? ContrasenaNueva { get; set; }
        /// <summary>IP del navegador, tal como la ve el ADM.</summary>
        public string? IpCliente { get; set; }
    }
}
