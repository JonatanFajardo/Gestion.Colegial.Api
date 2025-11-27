using Gestion.Colegial.DataAccess.Interfaces.Finanzas;
using Gestion.Colegial.Entities;
using Gestion.Colegial.Entities.DTOs.finansas;
using Microsoft.AspNetCore.Mvc;
using Gestion.Colegial.Business.Interfaces.ModuloFinanzas;

namespace Gestion.Colegial.Api.Controllers
{
    [ApiController]
    [Route("api/v1/[controller]")]
    public class ConceptosPagoController : ControllerBase
    {
        private readonly IConceptoPagoService _conceptoPagoService;

        public ConceptosPagoController(IConceptoPagoService conceptoPagoService)
        {
            _conceptoPagoService = conceptoPagoService;
        }

        [HttpGet]
        [Route("ListAsync")]
        public async Task<IActionResult> List()
        {
            Answer answer = await _conceptoPagoService.List();
            return Ok(answer.Data);
        }

        [HttpGet]
        [Route("FindAsync")]
        public async Task<IActionResult> Find(int value)
        {
            Answer answer = await _conceptoPagoService.Find(value);
            return Ok(answer.Data);
        }

        [HttpGet]
        [Route("DetailAsync")]
        public async Task<IActionResult> Detail(int value)
        {
            Answer answer = await _conceptoPagoService.Detail(value);
            return Ok(answer.Data);
        }

        [HttpPost]
        [Route("CreateAsync")]
        public async Task<IActionResult> Create([FromBody] ConceptoPagoFindDto entity)
        {
            Answer answer = await _conceptoPagoService.Create(entity);
            return Ok(answer.Data);
        }

        [HttpPut]
        [Route("EditAsync")]
        public async Task<IActionResult> Edit([FromBody] ConceptoPagoFindDto entity)
        {
            Answer answer = await _conceptoPagoService.Edit(entity);
            return Ok(answer.Data);
        }

        [HttpDelete]
        [Route("DeleteAsync")]
        public async Task<IActionResult> Delete(int value)
        {
            Answer answer = await _conceptoPagoService.Delete(value);
            return Ok(answer.Data);
        }

        [HttpGet]
        [Route("DropdownAsync")]
        public async Task<IActionResult> Dropdown()
        {
            Answer answer = await _conceptoPagoService.Dropdown();
            return Ok(answer.Data);
        }
    }
}
