using Gestion.Colegial.Entities;
using Microsoft.AspNetCore.Mvc;
using static Gestion.Colegial.Entities.Answer;

namespace Gestion.Colegial.Api.Controllers
{
    //[ApiController]
    //[Route("api/[controller]")]
    //[Route("api/Modalidades")]
    public class ApiBaseController : Controller
    {
        /// <summary>
        /// Recibe y evalúa los parámetros a través de múltiples condiciones.
        /// </summary>
        /// <param name="resultado">Valor retornado por el repositorio.</param>
        /// <param name="accion">Tipo de accion ejecutada</param>
        /// <returns>Devuelve el estado de la consulta o su valor.</returns>

        protected IActionResult Ok(Answer result)
        {
            switch (result.Type)
            {
                case ServiceResultType.Success:
                case ServiceResultType.Info:
                case ServiceResultType.Warning:
                    return Ok(result);

                case ServiceResultType.BadRequest:
                    return BadRequest(result);

                case ServiceResultType.NotFound:
                    return NotFound(result);

                case ServiceResultType.Unauthorized:
                    return Unauthorized(result);

                case ServiceResultType.Forbidden:
                    return StatusCode(403, result);

                case ServiceResultType.NotAcceptable:
                    return StatusCode(406, result);

                case ServiceResultType.Disabled:
                    return StatusCode(410, result);

                case ServiceResultType.Conflict:
                    return Conflict(result);

                default:
                case ServiceResultType.Error:
                    return StatusCode(500, result);
            }
        }

        public IActionResult Ok(Answer resultado, Accion accion)
        {
            if (resultado.Access)
            {
                return BadRequest(resultado.Message);
            }
            switch (accion)
            {
                case Accion.List:
                case Accion.Find:
                case Accion.Detail:
                case Accion.Dropdown:
                case Accion.Exist:
                    return Ok(resultado.Data);

                case Accion.Insert:
                case Accion.Update:
                    return Ok(resultado);

                case Accion.Remove:
                    return Ok(resultado.Access);

                default:
                    return BadRequest();
            }
        }

        public enum Accion
        {
            List,
            Find,
            Detail,
            Insert,
            Update,
            Dropdown,
            Exist,
            Remove
        }
    }
}