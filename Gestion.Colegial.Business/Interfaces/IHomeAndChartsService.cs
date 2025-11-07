using Gestion.Colegial.Entities;

namespace Gestion.Colegial.Business.Interfaces
{
    public interface IHomeAndChartsService
    {
        Task<Answer> DiferenciaEntreCantidadAlumnosAnioPasado_Dashboard();
        Task<Answer> ObtenerCantidadAlumnosPorCursoList();
        Task<Answer> ObtenerPromedioCursoUltimosAnios();
        Task<Answer> CardsInHomeList();
    }
}
