using Gestion.Colegial.Entities;
using Gestion.Colegial.Entities.DTOs;

namespace Gestion.Colegial.Business.Interfaces
{
    /// <summary>Ficha de salud del alumno: directorio, ficha, a quién llamar, historial y alertas del pase de lista.</summary>
    public interface IFichasSaludService
    {
        Task<Answer> Directorio(int? nivId, int? cunId, int? secId, string? texto, bool soloSinFicha, bool soloConAlerta);
        Task<Answer> Find(int aluId);
        Task<Answer> Contactos(int aluId);
        Task<Answer> Bitacora(int aluId);
        Task<Answer> AlertasSeccion(int horId, DateTime? fecha);
        Task<Answer> Guardar(FichaSaludGuardarDTO obj);
    }
}
