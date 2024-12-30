//using Entities.Entities;
//using System.Threading.Tasks;
//
//using System.Web.Http.Description;

//using Gestion.Colegial.Business.Services;


//namespace GESTION_COLEGIAL.API.Controllers
//{
//         [ApiController]
//[Route("api/v1/[controller]")]
////[Route("api/Personas")]
//    public class PersonasController : ControllerBase
//    {
//        //private PersonaService personaService = new PersonaService();

//        [HttpPost]
//        //[ResponseType(typeof(tbPersonas))]
//            [Route("CreateAsync")]
//        public async Task<IActionResult> Create(tbPersonas entity)
//        {
//            if (entity == null)
//            {
//                return NotFound();
//            }
//            Answer answer = await personaService.Create(entity);
//            return Ok(answer.Data);
//        }

//        ////[ResponseType(typeof(tbPersonas))]
//        //[HttpPut]
//        //    [Route("EditAsync")]
//        //public async Task<IActionResult> Edit(tbPersonas entity)
//        //{
//        //    if (entity == null)
//        //    {
//        //        return NotFound();
//        //    }
//        //    Answer answer = await personaService.Edit(entity);
//        //    return Ok(answer.Data);
//        //}

//        //[HttpGet]
//        ////[ResponseType(typeof(tbPersonas))]
//        //    [Route("ListAsync")]
//        //public async Task<IActionResult> List()
//        //{
//        //    Answer answer = await personaService.List();
//        //    return Ok(answer.Data);
//        //}

//        //[HttpGet]
//        ////[ResponseType(typeof(tbPersonas))]
//        //    [Route("FindAsync")]
//        //public async Task<IActionResult> Find(int value)
//        //{
//        //    if (value == 0)
//        //    {
//        //        return NotFound();
//        //    }
//        //    Answer answer = await personaService.Find(value);
//        //    return Ok(answer.Data);
//        //}

//        //[HttpPut]
//        ////[ResponseType(typeof(tbPersonas))]
//        //    [Route("RemoveAsync")]
//        //public async Task<IActionResult> Remove(int value)
//        //{
//        //    if (value == 0)
//        //    {
//        //        return NotFound();
//        //    }
//        //    Answer answer = await personaService.Delete(value);
//        //    return Ok(answer.Data);
//        //}
//    }
//}