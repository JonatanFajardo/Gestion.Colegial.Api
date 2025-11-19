using Gestion.Colegial.Business.Interfaces;
using Gestion.Colegial.Entities.DTOs;
using Microsoft.AspNetCore.Mvc;
using System.Threading.Tasks;

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

                var userIp = HttpContext.Connection.RemoteIpAddress?.ToString() ?? "Unknown";
                _logger.LogDebug("IP del usuario: {UserIp}", userIp);

                var result = await _usuarioService.AuthenticateAsync(loginRequest, userIp);

                if (result.Access)
                {
                    _logger.LogInformation("Login exitoso para usuario: {Username}", loginRequest.Username);
                    return Ok(result.Data);
                }
                else
                {
                    _logger.LogWarning("Login fallido para usuario: {Username}. Mensaje: {Message}", loginRequest.Username, result.Message);
                    return Unauthorized(result.Data);
                }
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, "Error en el proceso de login para usuario: {Username}", loginRequest.Username);
                return StatusCode(500, new { success = false, message = "Error interno del servidor" });
            }
        }

        [HttpPost("Logout")]
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
