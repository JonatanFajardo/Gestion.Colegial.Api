using Gestion.Colegial.Business.Interfaces;
using Gestion.Colegial.Entities;
using Gestion.Colegial.Entities.Entities;
using Microsoft.AspNetCore.Mvc;

namespace Gestion.Colegial.Api.Controllers
{
    /// <summary>
    /// Enfoque de enseñanza por año lectivo (Fase 3, espejo del Instructional Model de Skuul).
    /// Catálogo de 1 registro por año: FindAsync (value = Ani_Id) + SetAsync (upsert).
    /// </summary>
    [ApiController]
    [Route("api/v1/[controller]")]
    public class EnfoqueAnioController : ControllerBase
    {
        private readonly IEnfoqueAnioService _enfoqueAnioService;

        public EnfoqueAnioController(IEnfoqueAnioService enfoqueAnioService)
        {
            _enfoqueAnioService = enfoqueAnioService;
        }

        [HttpGet]
        [Route("FindAsync")]
        public async Task<IActionResult> Find(int value)
        {
            Answer answer = await _enfoqueAnioService.Find(value);
            return Ok(answer.Data);
        }

        [HttpPost]
        [Route("SetAsync")]
        public async Task<IActionResult> Set(tbEnfoqueAnio entity)
        {
            Answer answer = await _enfoqueAnioService.Set(entity);
            return Ok(answer.Data);
        }
    }
}
