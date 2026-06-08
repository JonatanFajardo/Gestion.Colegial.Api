using Gestion.Colegial.Business.Interfaces;
using Gestion.Colegial.Entities;
using Microsoft.AspNetCore.Mvc;
using System.Threading.Tasks;

namespace Gestion.Colegial.Api.Controllers
{
    [ApiController]
    [Route("api/v1/[controller]")]
    public class HorariosController : ControllerBase
    {
        private readonly IHorariosService _service;
        public HorariosController(IHorariosService service) { _service = service; }

        [HttpGet("ListAsync")]
        public async Task<IActionResult> List()
        {
            Answer answer = await _service.List();
            return Ok(answer.Data);
        }

        [HttpGet("FindAsync")]
        public async Task<IActionResult> Find(int Hor_Id)
        {
            Answer answer = await _service.Find(Hor_Id);
            return Ok(answer.Data);
        }

        [HttpPost("CreateAsync")]
        public async Task<IActionResult> Create([FromBody] HorarioCreateRequest request)
        {
            Answer answer = await _service.Insert(
                request.Cur_Id, request.Cun_Id, request.Mat_Id, request.Emp_Id, request.Sec_Id,
                request.Aul_Id, request.Dia_Id, request.Hor_HoraInicio, request.Hor_HoraFinaliza,
                request.Sem_Id, request.Mda_Id, request.Hor_Año, request.UsuarioRegistra);
            return Ok(answer);
        }

        [HttpPut("EditAsync")]
        public async Task<IActionResult> Edit([FromBody] HorarioEditRequest request)
        {
            Answer answer = await _service.Edit(
                request.Hor_Id, request.Cur_Id, request.Cun_Id, request.Mat_Id, request.Emp_Id,
                request.Sec_Id, request.Aul_Id, request.Dia_Id, request.Hor_HoraInicio,
                request.Hor_HoraFinaliza, request.Sem_Id, request.Mda_Id, request.Hor_Año,
                request.UsuarioModifica);
            return Ok(answer);
        }

        [HttpPut("RemoveAsync")]
        public async Task<IActionResult> Remove([FromBody] HorarioRemoveRequest request)
        {
            Answer answer = await _service.Remove(request.Hor_Id, request.UsuarioModifica);
            return Ok(answer);
        }
    }

    public class HorarioCreateRequest
    {
        public int Cur_Id { get; set; }
        public int Cun_Id { get; set; }
        public int Mat_Id { get; set; }
        public int Emp_Id { get; set; }
        public int Sec_Id { get; set; }
        public int Aul_Id { get; set; }
        public int Dia_Id { get; set; }
        public int Hor_HoraInicio { get; set; }
        public int Hor_HoraFinaliza { get; set; }
        public int Sem_Id { get; set; }
        public int? Mda_Id { get; set; }
        public int Hor_Año { get; set; }
        public int UsuarioRegistra { get; set; }
    }

    public class HorarioEditRequest : HorarioCreateRequest
    {
        public int Hor_Id { get; set; }
        public int UsuarioModifica { get; set; }
    }

    public class HorarioRemoveRequest
    {
        public int Hor_Id { get; set; }
        public int UsuarioModifica { get; set; }
    }
}
