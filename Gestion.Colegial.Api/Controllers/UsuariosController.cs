using Gestion.Colegial.Business.Interfaces;
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

        public UsuariosController(IUsuarioService usuarioService)
        {
            _usuarioService = usuarioService;
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
        public async Task<IActionResult> Create(tbUsuarios entity)
        {
            Answer answer = await _usuarioService.Create(entity);
            return Ok(answer.Data);
        }

        [HttpPut]
        [Route("EditAsync")]
        public async Task<IActionResult> Edit(tbUsuarios entity)
        {
            Answer answer = await _usuarioService.Edit(entity);
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
