using System.ComponentModel.DataAnnotations;

namespace Gestion.Colegial.Entities.DTOs
{
    public class LoginRequestDTO
    {
        [Required(ErrorMessage = "El nombre de usuario es requerido")]
        public string Username { get; set; }

        [Required(ErrorMessage = "La contrasena es requerida")]
        public string Password { get; set; }

        public bool RememberMe { get; set; }

        /// <summary>IP del navegador, tal como la ve el ADM (la API solo ve la del ADM).</summary>
        public string? IpCliente { get; set; }
    }
}