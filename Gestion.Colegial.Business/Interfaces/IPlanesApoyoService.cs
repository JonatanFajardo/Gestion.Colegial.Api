using Gestion.Colegial.Entities;
using Gestion.Colegial.Entities.DTOs;

namespace Gestion.Colegial.Business.Interfaces
{
    /// <summary>Plan de apoyo al alumno: planes, pasos, notas e historial de estados.</summary>
    public interface IPlanesApoyoService
    {
        Task<Answer> List(bool verTodos, bool verConfidenciales, int? usuId);
        Task<Answer> Resumen(bool verTodos, bool verConfidenciales, int? usuId);
        Task<Answer> Find(int id, bool verTodos, bool verConfidenciales, int? usuId);
        Task<Answer> Pasos(int id, bool verTodos, bool verConfidenciales, int? usuId);
        Task<Answer> Notas(int id, bool verTodos, bool verConfidenciales, int? usuId);
        Task<Answer> Estados(int id, bool verTodos, bool verConfidenciales, int? usuId);
        Task<Answer> Usuarios();
        Task<Answer> Alumnos();
        Task<Answer> Secciones(int cunId);
        Task<Answer> AbiertosDeAlumnos(string? alumnos, bool verTodos, bool verConfidenciales, int? usuId);
        Task<Answer> Crear(PlanApoyoGuardarDTO obj);
        Task<Answer> Editar(PlanApoyoGuardarDTO obj);
        Task<Answer> CambiarEstado(PlanApoyoEstadoDTO obj);
        Task<Answer> AgregarPaso(PlanApoyoPasoDTO obj);
        Task<Answer> CompletarPaso(PlanApoyoPasoAccionDTO obj);
        Task<Answer> QuitarPaso(PlanApoyoPasoAccionDTO obj);
        Task<Answer> AgregarNota(PlanApoyoNotaDTO obj);
        Task<Answer> Eliminar(PlanApoyoEliminarDTO obj);
    }
}
