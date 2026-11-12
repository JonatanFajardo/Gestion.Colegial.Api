using Gestion.Colegial.Entities;

namespace Gestion.Colegial.Business.Interfaces
{
    public interface IGraduacionService
    {
        Task<Answer> ListCandidatos();
        Task<Answer> GraduarAlumno(int aluId, int usuarioId);
        Task<Answer> Backfill(int? anio, int topN, bool dryRun);
        Task<Answer> ListGraduados();
        Task<Answer> FindGraduado(int aluGradId);
    }
}
