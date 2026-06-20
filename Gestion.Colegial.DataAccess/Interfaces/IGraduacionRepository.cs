using Gestion.Colegial.Entities;

namespace Gestion.Colegial.DataAccess.Interfaces
{
    public interface IGraduacionRepository
    {
        Task<Answer> ListCandidatos();
        Task<Answer> GraduarAlumno(int aluId, int usuarioId);
        Task<Answer> Backfill(int? anio, int topN, bool dryRun);
        Task<Answer> ListGraduados();
        Task<Answer> FindGraduado(int aluGradId);
    }
}
