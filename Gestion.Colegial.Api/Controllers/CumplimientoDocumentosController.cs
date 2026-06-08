using Gestion.Colegial.Business.Interfaces;
using Gestion.Colegial.Entities;
using Microsoft.AspNetCore.Mvc;
using System.Threading.Tasks;

namespace Gestion.Colegial.Api.Controllers
{
    [ApiController]
    [Route("api/v1/[controller]")]
    public class CumplimientoDocumentosController : ControllerBase
    {
        private readonly ICumplimientoDocumentosService _service;
        public CumplimientoDocumentosController(ICumplimientoDocumentosService service) { _service = service; }

        [HttpGet("ListAsync")]
        public async Task<IActionResult> List(int? Emp_Id)
        {
            Answer answer = await _service.List(Emp_Id);
            return Ok(answer.Data);
        }
    }
}
