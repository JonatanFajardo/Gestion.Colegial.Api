using Gestion.Colegial.Entities;
using Gestion.Colegial.Entities.DTOs;

namespace Gestion.Colegial.Business.Interfaces
{
    /// <summary>Notas ponderadas: plantillas de evaluación (Dirección) y actividades del cuaderno (docente).</summary>
    public interface IEvaluacionesService
    {
        Task<Answer> Cuaderno(int horId, int pacId, int usuId);
        Task<bool> UsaActividades(int horId, int pacId);
        Task<Answer> GuardarActividad(ActividadEvaluacionGuardarDTO obj);
        Task<Answer> QuitarActividad(ActividadEvaluacionQuitarDTO obj);
        Task<Answer> GuardarPuntos(PuntosEvaluacionGuardarDTO obj);
        Task<Answer> ActualizarNotas(int cevId, int usuId);
        Task<Answer> Plantillas(int anio, int usuId);
        Task<Answer> Opciones(int usuId, string? tipo, int? anio, int? nivId);
        Task<Answer> GuardarPlantilla(PlantillaEvaluacionGuardarDTO obj);
        Task<Answer> QuitarPlantilla(PlantillaEvaluacionQuitarDTO obj);
        Task<Answer> Avance(int anio, int semId, int pacId, int usuId);
    }
}
