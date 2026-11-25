using Gestion.Colegial.Entities;

namespace Gestion.Colegial.DataAccess.Interfaces
{
    public interface IAnioConexionRepository
    {
        Task<Answer> Cupos(int aniId);
        Task<Answer> ActualizarCupo(int seaId, int cupo, int? usuario);
        Task<Answer> AniosInscripcion();
        Task<Answer> VerificarCupo(int? aniId, int nivId, int cunId, int? mdaId, int secId);
        Task<Answer> InscribirAlumno(int aluId, int? aniId, int? usuario);
        Task<Answer> AplicarUbicacion(int aniId, int? usuario, bool activar);
        Task<Answer> UbicacionPrevia(int aniId);
        Task<Answer> Semestres(int anio);
    }
}
