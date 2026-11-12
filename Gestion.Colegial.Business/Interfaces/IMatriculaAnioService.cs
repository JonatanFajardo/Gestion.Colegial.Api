using Gestion.Colegial.Entities;
using Gestion.Colegial.Entities.Entities;

namespace Gestion.Colegial.Business.Interfaces
{
    public interface IMatriculaAnioService
    {
        Task<Answer> ListBySeccion(int seaId);
        Task<Answer> Expediente(int aluId);
        Task<Answer> Enroll(tbMatriculaAnio obj);
        Task<Answer> Promover(int anioOrigen, int seccionOrigen, int anioDestino, int seccionDestino);
        Task<Answer> ResumenInscripcion(int? aniId);
        Task<Answer> CrearSeccionesDesdeUbicacion(int? aniId, int? aluId, int? usuario);
        Task<Answer> InscribirDesdeUbicacion(int? aniId, int? aluId, bool crearSecciones, bool activarEstado, int? usuario);
    }
}
