using Gestion.Colegial.Api.Seguridad;
using Gestion.Colegial.Business.Interfaces;
using Gestion.Colegial.Business.Seguridad;
using Gestion.Colegial.Entities;
using Gestion.Colegial.Entities.Entities;
using Microsoft.AspNetCore.Mvc;

namespace Gestion.Colegial.Api.Controllers
{
    [ApiController]
    [Route("api/v1/[controller]")]
    public class UsuariosController : ControllerBase
    {
        private readonly IUsuarioService _usuarioService;
        private readonly IUsuarioActual _usuarioActual;

        public UsuariosController(IUsuarioService usuarioService, IUsuarioActual usuarioActual)
        {
            _usuarioService = usuarioService;
            _usuarioActual = usuarioActual;
        }

        [HttpGet]
        [Route("ListAsync")]
        public async Task<IActionResult> List()
        {
            Answer answer = await _usuarioService.List();
            return Ok(answer.Data);
        }

        [HttpGet]
        [Route("FindAsync")]
        public async Task<IActionResult> Find(int value)
        {
            Answer answer = await _usuarioService.Find(value);
            return Ok(answer.Data);
        }

        [HttpGet]
        [Route("DetailAsync")]
        public async Task<IActionResult> Detail(int value)
        {
            Answer answer = await _usuarioService.Detail(value);
            return Ok(answer.Data);
        }

        [HttpPost]
        [Route("CreateAsync")]
        [RequierePantalla("Listado de usuarios")]
        public async Task<IActionResult> Create(tbUsuarios entity)
        {
            // Sin contraseña por omisión: quien crea la cuenta escribe la inicial.
            string? problema = NombresUsuario.Validar(entity.Usu_Name)
                ?? Contrasenas.Validar(entity.Usu_Contraseña, entity.Usu_Name);
            if (problema != null)
            {
                return BadRequest(new { Message = problema });
            }
            entity.Usu_Name = entity.Usu_Name.Trim();
            Answer answer = await _usuarioService.Create(entity);
            if (answer.Access)
            {
                return BadRequest(new { Message = "No se pudo guardar el usuario. Revise que el nombre no esté en uso." });
            }
            return Ok(answer.Data);
        }

        [HttpPut]
        [Route("EditAsync")]
        [RequierePantalla("Listado de usuarios")]
        public async Task<IActionResult> Edit(tbUsuarios entity)
        {
            // Si viene una contraseña, se restablece (mismo camino que cualquier cambio de contraseña).
            string? nombreMalo = NombresUsuario.Validar(entity.Usu_Name);
            if (nombreMalo != null)
            {
                return BadRequest(new { Message = nombreMalo });
            }
            entity.Usu_Name = entity.Usu_Name.Trim();

            bool restablece = !string.IsNullOrEmpty(entity.Usu_Contraseña);
            if (restablece)
            {
                string? problema = Contrasenas.Validar(entity.Usu_Contraseña, entity.Usu_Name);
                if (problema != null)
                {
                    return BadRequest(new { Message = problema });
                }
            }

            Answer answer = await _usuarioService.Edit(entity);
            if (answer.Access)
            {
                return BadRequest(new { Message = "No se pudo guardar el usuario. Revise que el nombre no esté en uso." });
            }

            if (restablece)
            {
                Answer clave = await _usuarioService.GuardarContrasenaAsync(entity.Usu_Id, entity.Usu_Name, entity.Usu_Contraseña,
                    _usuarioActual.UsuId, "Restablecer contraseña", null);
                if (clave.Access)
                {
                    return BadRequest(new { Message = clave.Message });
                }
            }
            return Ok(answer.Data);
        }

        [HttpGet]
        [Route("ExistAsync")]
        public async Task<IActionResult> Exist(string value)
        {
            if (value == null)
            {
                return NotFound();
            }
            Answer answer = await _usuarioService.Exist(value);

            if (answer.Access)
            {
                return BadRequest(answer.Message);
            }
            return Ok(answer.Data);
        }

        [HttpPut]
        [Route("RemoveAsync")]
        [RequierePantalla("Listado de usuarios")]
        public async Task<IActionResult> Remove(int value)
        {
            Answer answer = await _usuarioService.Delete(value);
            return Ok(answer.Data);
        }

        [HttpGet]
        [Route("RolesDropdownAsync")]
        public async Task<IActionResult> RolesDropdown()
        {
            Answer answer = await _usuarioService.RolesDropdown();
            return Ok(answer.Data);
        }
    }
}
