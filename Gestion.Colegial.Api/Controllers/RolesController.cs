using Gestion.Colegial.Business.Interfaces;
using Gestion.Colegial.Entities;
using Gestion.Colegial.Entities.DTOs;
using Gestion.Colegial.Entities.Entities;
using Microsoft.AspNetCore.Mvc;

namespace Gestion.Colegial.Api.Controllers
{
    [ApiController]
    [Route("api/v1/[controller]")]
    public class RolesController : ControllerBase
    {
        private readonly IRolesService _rolesService;

        public RolesController(IRolesService rolesService)
        {
            _rolesService = rolesService;
        }

        [HttpGet]
        [Route("ListAsync")]
        public async Task<IActionResult> List()
        {
            Answer answer = await _rolesService.List();
            return Ok(answer.Data);
        }

        [HttpGet]
        [Route("FindAsync")]
        public async Task<IActionResult> Find(int value)
        {
            Answer answer = await _rolesService.Find(value);
            return Ok(answer.Data);
        }

        [HttpGet]
        [Route("DetailAsync")]
        public async Task<IActionResult> Detail(int value)
        {
            Answer answer = await _rolesService.Detail(value);
            return Ok(answer.Data);
        }

        [HttpPost]
        [Route("CreateAsync")]
        public async Task<IActionResult> Create(tbRoles entity)
        {
            Answer answer = await _rolesService.Create(entity);
            return Ok(answer.Data);
        }

        [HttpPut]
        [Route("EditAsync")]
        public async Task<IActionResult> Edit(tbRoles entity)
        {
            Answer answer = await _rolesService.Edit(entity);
            return Ok(answer.Data);
        }

        [HttpGet]
        [Route("ExistAsync")]
        public async Task<IActionResult> Exist(string value)
        {
            if (value == null) return NotFound();
            Answer answer = await _rolesService.Exist(value);
            if (answer.Access) return BadRequest(answer.Message);
            return Ok(answer.Data);
        }

        [HttpPut]
        [Route("RemoveAsync")]
        public async Task<IActionResult> Remove(int value)
        {
            Answer answer = await _rolesService.Delete(value);
            return Ok(answer.Data);
        }

        [HttpGet]
        [Route("PantallasListAsync")]
        public async Task<IActionResult> PantallasList()
        {
            Answer answer = await _rolesService.PantallasList();
            return Ok(answer.Data);
        }

        [HttpGet]
        [Route("PantallasByRolAsync")]
        public async Task<IActionResult> PantallasByRol(int value)
        {
            Answer answer = await _rolesService.PantallasByRol(value);
            return Ok(answer.Data);
        }

        [HttpPost]
        [Route("SavePantallasAsync")]
        public async Task<IActionResult> SavePantallas(RolConPantallasDTO dto)
        {
            Answer answer = await _rolesService.SavePantallas(dto.Rol_Id, dto.PantallaIds);
            return Ok(answer.Data);
        }
    }
}
