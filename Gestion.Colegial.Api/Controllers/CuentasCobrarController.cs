using Gestion.Colegial.Business.Interfaces;
using Gestion.Colegial.Entities;
using Gestion.Colegial.Entities.DTOs.finansas;
using Microsoft.AspNetCore.Mvc;

namespace Gestion.Colegial.Api.Controllers
{
    [ApiController]
    [Route("api/v1/[controller]")]
    public class CuentasCobrarController : ControllerBase
    {
        private readonly ICuentaCobrarService _cuentaCobrarService;

        public CuentasCobrarController(ICuentaCobrarService cuentaCobrarService)
        {
            _cuentaCobrarService = cuentaCobrarService;
        }

        [HttpGet]
        [Route("ListAsync")]
        public async Task<IActionResult> List()
        {
            Answer answer = await _cuentaCobrarService.List();
            return Ok(answer.Data);
        }

        [HttpGet]
        [Route("ListByAlumnoAsync")]
        public async Task<IActionResult> ListByAlumno(int alumnoId)
        {
            Answer answer = await _cuentaCobrarService.ListByAlumno(alumnoId);
            return Ok(answer.Data);
        }

        [HttpGet]
        [Route("ListPendientesAsync")]
        public async Task<IActionResult> ListPendientes()
        {
            Answer answer = await _cuentaCobrarService.ListPendientes();
            return Ok(answer.Data);
        }

        [HttpGet]
        [Route("ListVencidasAsync")]
        public async Task<IActionResult> ListVencidas()
        {
            Answer answer = await _cuentaCobrarService.ListVencidas();
            return Ok(answer.Data);
        }

        [HttpGet]
        [Route("FindAsync")]
        public async Task<IActionResult> Find(int value)
        {
            Answer answer = await _cuentaCobrarService.Find(value);
            return Ok(answer.Data);
        }

        [HttpGet]
        [Route("DetailAsync")]
        public async Task<IActionResult> Detail(int value)
        {
            Answer answer = await _cuentaCobrarService.Detail(value);
            return Ok(answer.Data);
        }

        [HttpPost]
        [Route("CreateAsync")]
        public async Task<IActionResult> Create([FromBody] CuentaCobrarFindDto entity)
        {
            Answer answer = await _cuentaCobrarService.Create(entity);
            return Ok(answer.Data);
        }

        [HttpPut]
        [Route("EditAsync")]
        public async Task<IActionResult> Edit([FromBody] CuentaCobrarFindDto entity)
        {
            Answer answer = await _cuentaCobrarService.Edit(entity);
            return Ok(answer.Data);
        }

        [HttpDelete]
        [Route("DeleteAsync")]
        public async Task<IActionResult> Delete(int value)
        {
            Answer answer = await _cuentaCobrarService.Delete(value);
            return Ok(answer.Data);
        }

        [HttpPost]
        [Route("GenerarCargosAlumnoAsync")]
        public async Task<IActionResult> GenerarCargosAlumno(int alumnoId, int anio)
        {
            Answer answer = await _cuentaCobrarService.GenerarCargosAlumno(alumnoId, anio);
            return Ok(answer.Data);
        }

        [HttpPost]
        [Route("AplicarDescuentoAsync")]
        public async Task<IActionResult> AplicarDescuento(int cuentaCobrarId, int descuentoId, decimal monto, string justificacion)
        {
            Answer answer = await _cuentaCobrarService.AplicarDescuento(cuentaCobrarId, descuentoId, monto, justificacion);
            return Ok(answer.Data);
        }

        [HttpPost]
        [Route("CalcularMoratoriaAsync")]
        public async Task<IActionResult> CalcularMoratoria(int cuentaCobrarId)
        {
            Answer answer = await _cuentaCobrarService.CalcularMoratoria(cuentaCobrarId);
            return Ok(answer.Data);
        }
    }
}
