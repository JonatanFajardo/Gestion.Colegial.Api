using Gestion.Colegial.Business.Interfaces;
using Gestion.Colegial.Entities;
using Microsoft.AspNetCore.Mvc;
using System.Threading.Tasks;
using Gestion.Colegial.Api.Seguridad;

namespace Gestion.Colegial.Api.Controllers
{
    [ApiController]
    [Route("api/v1/[controller]")]
    [DatoDelServidor(DatoUsuario.Usuario, "usuId")]
    public class PerfilController : ControllerBase
    {
        private readonly IPerfilService _service;

        public PerfilController(IPerfilService service)
        {
            _service = service;
        }

        [HttpGet("FindAsync")]
        public async Task<IActionResult> Find(int usuId)
        {
            Answer answer = await _service.Find(usuId);
            return Ok(answer.Data);
        }
    }
}
