using Gestion.Colegial.Entities;
using Gestion.Colegial.Entities.DTOs;

namespace Gestion.Colegial.DataAccess.Interfaces
{
    /// <summary>Notas ponderadas: plantillas de evaluación y actividades del cuaderno (script 089).</summary>
    public interface IEvaluacionesRepository
    {
        Task<Answer> Cuaderno(int horId, int pacId, int usuId);
        Task<Answer> UsaActividades(int horId, int pacId);
        Task<Answer> NotasParaEscribir(int? cevId, int? pleId, int usuId);
        Task<Answer> GuardarActividad(ActividadEvaluacionGuardarDTO obj);
        Task<Answer> QuitarActividad(ActividadEvaluacionQuitarDTO obj);
        Task<Answer> GuardarPuntos(PuntosEvaluacionGuardarDTO obj);
        Task<Answer> Plantillas(int anio, int usuId);
        Task<Answer> Opciones(int usuId, string tipo, int? anio, int? nivId);
        Task<Answer> GuardarPlantilla(PlantillaEvaluacionGuardarDTO obj);
        Task<Answer> QuitarPlantilla(PlantillaEvaluacionQuitarDTO obj);
        Task<Answer> Avance(int anio, int semId, int pacId, int usuId);
    }
}
