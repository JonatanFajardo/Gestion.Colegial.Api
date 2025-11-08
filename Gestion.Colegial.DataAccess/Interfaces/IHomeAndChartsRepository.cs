using Gestion.Colegial.Entities;

namespace Gestion.Colegial.DataAccess.Interfaces
{
    public interface IHomeAndChartsRepository
    {
        Task<Answer> DiferenciaEntreCantidadAlumnosAnioPasado_Dashboard();

        Task<Answer> ObtenerCantidadAlumnosPorCursoList();

        Task<Answer> ObtenerPromedioCursoUltimosAnios();

        Task<Answer> CardsInHomeList();
    }
}