using Gestion.Colegial.Entities;
using Gestion.Colegial.Entities.DTOs;

namespace Gestion.Colegial.Business.Interfaces
{
    public interface IAnioConexionService
    {
        Task<Answer> Cupos(int aniId);
        Task<Answer> ActualizarCupo(CupoSeccionDTO obj);
        Task<Answer> AniosInscripcion();
        Task<Answer> VerificarCupo(int? aniId, int nivId, int cunId, int? mdaId, int secId);
        Task<Answer> InscribirAlumno(InscribirAlumnoDTO obj);
        Task<Answer> AplicarUbicacion(AplicarUbicacionDTO obj);
        Task<Answer> Semestres(int anio);
    }
}
