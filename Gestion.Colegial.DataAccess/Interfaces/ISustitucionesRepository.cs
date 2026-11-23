using Gestion.Colegial.Entities;
using Gestion.Colegial.Entities.DTOs;

namespace Gestion.Colegial.DataAccess.Interfaces
{
    /// <summary>Sustitución de docente: ausencias, clases a cubrir, suplentes e historial (script 073).</summary>
    public interface ISustitucionesRepository
    {
        Task<Answer> Dia(DateTime fecha, int? empId);
        Task<Answer> Mes(DateTime fecha, int? empId);
        Task<Answer> Sugerencias(int horId, DateTime fecha);
        Task<Answer> Docentes(DateTime fecha);
        Task<Answer> Historial(DateTime desde, DateTime hasta, int? empId);
        Task<Answer> Asignar(SustitucionAsignarDTO obj);
        Task<Answer> Cancelar(SustitucionCancelarDTO obj);
        Task<Answer> MarcarAusencia(AusenciaDocenteMarcarDTO obj);
        Task<Answer> QuitarAusencia(AusenciaDocenteQuitarDTO obj);
    }
}
