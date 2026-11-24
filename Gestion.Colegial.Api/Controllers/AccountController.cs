using Gestion.Colegial.Business.Interfaces;
using Gestion.Colegial.Entities.DTOs;
using Microsoft.AspNetCore.Mvc;
using System.Net;
using System.Threading.Tasks;
using Gestion.Colegial.Api.Seguridad;

namespace Gestion.Colegial.Api.Controllers
{
    [Route("api/v1/[controller]")]
    [ApiController]
    public class AccountController : ControllerBase
    {
        private readonly IUsuarioService _usuarioService;
        private readonly ILogger<AccountController> _logger;

        public AccountController(IUsuarioService usuarioService, ILogger<AccountController> logger)
        {
            _usuarioService = usuarioService;
            _logger = logger;
        }

        [HttpPost("Login")]
        public async Task<IActionResult> Login([FromBody] LoginRequestDTO loginRequest)
        {
            try
            {
                _logger.LogInformation("Iniciando proceso de login para usuario: {Username}", loginRequest.Username);

                if (!ModelState.IsValid)
                {
                    _logger.LogWarning("ModelState inválido en login para usuario: {Username}", loginRequest.Username);
                    return BadRequest(ModelState);
                }

                var userIp = IpDelCliente(loginRequest.IpCliente);
                _logger.LogDebug("IP del usuario: {UserIp}", userIp);

                var result = await _usuarioService.AuthenticateAsync(loginRequest, userIp);

                if (result.Access)
                {
                    _logger.LogInformation("Login exitoso para usuario: {Username}", loginRequest.Username);
                    return Ok(result.Data);
                }
                else
                {
                    // 200 con Success = false: el ADM solo lee el cuerpo de las respuestas correctas y así
                    // puede mostrar el mensaje (credenciales incorrectas o bloqueo por intentos).
                    _logger.LogWarning("Login fallido para usuario: {Username} desde {Ip}. Mensaje: {Message}", loginRequest.Username, userIp, result.Message);
                    return Ok(result.Data);
                }
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, "Error en el proceso de login para usuario: {Username}", loginRequest.Username);
                return StatusCode(500, new { success = false, message = "Error interno del servidor" });
            }
        }

        /// <summary>Cambio de la propia contraseña (el Usu_Id lo pone la API con el usuario firmado).</summary>
        [HttpPost("CambiarContrasena")]
        [DatoDelServidor(DatoUsuario.Usuario, "Usu_Id")]
        public async Task<IActionResult> CambiarContrasena([FromBody] CambiarContrasenaDTO dto)
        {
            dto.IpCliente = IpDelCliente(dto.IpCliente);
            var result = await _usuarioService.CambiarContrasenaAsync(dto);
            if (result.Access)
            {
                return BadRequest(new { Message = result.Message });
            }
            return Ok(new { Message = result.Message });
        }

        /// <summary>
        /// IP del navegador. La manda el ADM (la API solo ve la del ADM); si no viene o no es una IP
        /// válida, se usa la de la conexión.
        /// </summary>
        private string IpDelCliente(string? enviada)
        {
            if (!string.IsNullOrWhiteSpace(enviada) && enviada.Length <= 45 && IPAddress.TryParse(enviada.Trim(), out IPAddress? ip))
            {
                return (ip.IsIPv4MappedToIPv6 ? ip.MapToIPv4() : ip).ToString();
            }
            IPAddress? conexion = HttpContext.Connection.RemoteIpAddress;
            return conexion == null ? "Unknown" : (conexion.IsIPv4MappedToIPv6 ? conexion.MapToIPv4() : conexion).ToString();
        }

        [HttpPost("Logout")]
        [DatoDelServidor(DatoUsuario.Usuario, "usuId")]
        public async Task<IActionResult> Logout([FromBody] int usuId)
        {
            try
            {
                _logger.LogInformation("Iniciando proceso de logout para usuario ID: {UsuarioId}", usuId);

                var result = await _usuarioService.LogoutAsync(usuId);

                if (result.Access)
                {
                    _logger.LogInformation("Logout exitoso para usuario ID: {UsuarioId}", usuId);
                    return Ok(new { success = true, message = result.Message });
                }
                else
                {
                    _logger.LogWarning("Logout fallido para usuario ID: {UsuarioId}. Mensaje: {Message}", usuId, result.Message);
                    return StatusCode(500, new { success = false, message = result.Message });
                }
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, "Error en el proceso de logout para usuario ID: {UsuarioId}", usuId);
                return StatusCode(500, new { success = false, message = "Error interno del servidor" });
            }
        }
    }
}
