using Gestion.Colegial.Business.Interfaces;
using Gestion.Colegial.Entities;
using Gestion.Colegial.Entities.DTOs.finansas;
using Microsoft.AspNetCore.Mvc;

namespace Gestion.Colegial.Api.Controllers
{
    [ApiController]
    [Route("api/v1/[controller]")]
    public class DescuentosController : ControllerBase
    {
        private readonly IDescuentoService _descuentoService;

        public DescuentosController(IDescuentoService descuentoService)
        {
            _descuentoService = descuentoService;
        }

        [HttpGet]
        [Route("ListAsync")]
        public async Task<IActionResult> List()
        {
            Answer answer = await _descuentoService.List();
            return Ok(answer.Data);
        }

        [HttpGet]
        [Route("FindAsync")]
        public async Task<IActionResult> Find(int value)
        {
            Answer answer = await _descuentoService.Find(value);
            return Ok(answer.Data);
        }

        [HttpGet]
        [Route("DetailAsync")]
        public async Task<IActionResult> Detail(int value)
        {
            Answer answer = await _descuentoService.Detail(value);
            return Ok(answer.Data);
        }

        [HttpPost]
        [Route("CreateAsync")]
        public async Task<IActionResult> Create([FromBody] DescuentoFindDto entity)
        {
            Answer answer = await _descuentoService.Create(entity);
            return Ok(answer.Data);
        }

        [HttpPut]
        [Route("EditAsync")]
        public async Task<IActionResult> Edit([FromBody] DescuentoFindDto entity)
        {
            Answer answer = await _descuentoService.Edit(entity);
            return Ok(answer.Data);
        }

        [HttpDelete]
        [Route("DeleteAsync")]
        public async Task<IActionResult> Delete(int value)
        {
            Answer answer = await _descuentoService.Delete(value);
            return Ok(answer.Data);
        }

        [HttpGet]
        [Route("DropdownAsync")]
        public async Task<IActionResult> Dropdown()
        {
            Answer answer = await _descuentoService.Dropdown();
            return Ok(answer.Data);
        }
    }
}
