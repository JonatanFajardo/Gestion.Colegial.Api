using Gestion.Colegial.Entities;
using Gestion.Colegial.Entities.DTOs;

namespace Gestion.Colegial.Business.Interfaces
{
    /// <summary>Disciplina: casos de conducta y de protección del menor (reservados).</summary>
    public interface ICasosDisciplinaService
    {
        Task<Answer> List(string? estado, string? tipo, bool soloAbiertos, bool verReservados, int? usuId, int? empId, int pagina);
        Task<Answer> Abiertos(bool verReservados, int? usuId, int? empId);
        Task<Answer> Find(int id, bool verReservados, int? usuId, int? empId);
        Task<Answer> Personas(int id);
        Task<Answer> Acciones(int id);
        Task<Answer> Estados(int id);
        Task<Answer> Notas(int id, bool verReservados, int? usuId, int? empId);
        Task<Answer> Alumnos();
        Task<Answer> Empleados();
        Task<Answer> Registrar(CasoDisciplinaRegistrarDTO obj);
        Task<Answer> CambiarEstado(CasoDisciplinaEstadoDTO obj);
        Task<Answer> AgregarAccion(CasoDisciplinaAccionDTO obj);
        Task<Answer> CompletarAccion(int casId, int cacId, int? usuario);
        Task<Answer> AgregarNota(CasoDisciplinaNotaDTO obj);
    }
}
