using Gestion.Colegial.Entities;
using Gestion.Colegial.Entities.Entities;

namespace Gestion.Colegial.DataAccess.Interfaces
{
    public interface IMatriculaAnioRepository
    {
        Task<Answer> ListBySeccion(int seaId);
        Task<Answer> Expediente(int aluId);
        Task<Answer> Enroll(tbMatriculaAnio obj);
        Task<Answer> Promover(int anioOrigen, int seccionOrigen, int anioDestino, int seccionDestino);
    }
}
