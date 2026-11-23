using Gestion.Colegial.Entities;
using Gestion.Colegial.Entities.DTOs;

namespace Gestion.Colegial.DataAccess.Interfaces
{
    /// <summary>Ficha de salud del alumno (script 070).</summary>
    public interface IFichasSaludRepository
    {
        Task<Answer> Directorio(int? nivId, int? cunId, int? secId, string? texto, bool soloSinFicha, bool soloConAlerta);
        Task<Answer> Find(int aluId);
        Task<Answer> Contactos(int aluId);
        Task<Answer> Bitacora(int aluId);
        Task<Answer> AlertasSeccion(int horId, DateTime? fecha, int? usuId);
        Task<Answer> Guardar(FichaSaludGuardarDTO obj);
    }
}
