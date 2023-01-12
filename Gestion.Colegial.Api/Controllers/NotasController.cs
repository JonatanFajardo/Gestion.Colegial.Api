using Microsoft.AspNetCore.Mvc;

namespace Gestion.Colegial.Api.Controllers
{
    [ApiController]
    [Route("api/[controller]")]
    //[Route("api/Notas")]
    public class NotasController : ControllerBase
    {
        //private NotaService notaService = new NotaService();

        //[HttpPost]
        ////[ResponseType(typeof(tbNotas))]
        //    [Route("CreateAsync")]
        //public async Task<IActionResult> Create(tbNotas entity)
        //{
        //    if (entity == null)
        //    {
        //        return NotFound();
        //    }
        //    Answer answer = await notaService.Create(entity);
        //    return Ok(answer.Data);
        //}

        ////[ResponseType(typeof(tbNotas))]
        //[HttpPut]
        //    [Route("EditAsync")]
        //public async Task<IActionResult> Edit(tbNotas entity)
        //{
        //    if (entity == null)
        //    {
        //        return NotFound();
        //    }
        //    Answer answer = await notaService.Edit(entity);
        //    return Ok(answer.Data);
        //}

        //[HttpGet]
        ////[ResponseType(typeof(tbNotas))]
        //    [Route("ListAsync")]
        //public async Task<IActionResult> List()
        //{
        //    Answer answer = await notaService.List();
        //    return Ok(answer.Data);
        //}

        //[HttpGet]
        ////[ResponseType(typeof(tbNotas))]
        //    [Route("FindAsync")]
        //public async Task<IActionResult> Find(int value)
        //{
        //    if (value == 0)
        //    {
        //        return NotFound();
        //    }
        //    Answer answer = await notaService.Find(value);
        //    return Ok(answer.Data);
        //}

        //[HttpPut]
        ////[ResponseType(typeof(tbNotas))]
        //    [Route("RemoveAsync")]
        //public async Task<IActionResult> Remove(int value)
        //{
        //    if (value == 0)
        //    {
        //        return NotFound();
        //    }
        //    Answer answer = await notaService.Delete(value);
        //    return Ok(answer.Data);
        //}
    }
}
