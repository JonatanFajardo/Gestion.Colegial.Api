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

        public AccountController(IUsuarioService usuarioService)
        {
            _usuarioService = usuarioService;
        }

        [HttpPost("Login")]
        public async Task<IActionResult> Login([FromBody] LoginRequestDTO loginRequest)
        {
            if (!ModelState.IsValid)
            {
                return BadRequest(ModelState);
            }

            var userIp = HttpContext.Connection.RemoteIpAddress?.ToString();
            var result = await _usuarioService.AuthenticateAsync(loginRequest, userIp);

            if (result.Access)
            {
                return Ok(result.Data);
            }
            else
            {
                return Unauthorized(result.Data);
            }
        }

        [HttpPost("Logout")]
        public async Task<IActionResult> Logout([FromBody] int usuId)
        {
            var result = await _usuarioService.LogoutAsync(usuId);

            if (result.Access)
            {
                return Ok(new { success = true, message = result.Message });
            }
            else
            {
                return StatusCode(500, new { success = false, message = result.Message });
            }
        }
    }
}
