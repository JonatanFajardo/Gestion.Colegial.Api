using Microsoft.AspNetCore.Mvc;

namespace Gestion.Colegial.Api.Controllers
{
    //     [ApiController]
    [Route("api/[controller]")]
    //[Route("api/Modalidades")]
    public class ValuesController : ControllerBase
    {
        // GET api/values
        public IEnumerable<string> Get()
        {
            return new string[] { "value1", "value2" };
        }

        // GET api/values/5
        public string Get(int id)
        {
            return "value";
        }

        // POST api/values
        public void Post([FromBody] string value)
        {
        }

        // PUT api/values/5
        public void Put(int id, [FromBody] string value)
        {
        }

        public void Delete(int id)
        {
        }
    }
}
