using Gestion.Colegial.Entities;
using Gestion.Colegial.Entities.DTOs;

namespace Gestion.Colegial.DataAccess.Interfaces
{
    /// <summary>Lista de espera de admisión: aspirantes, su cola por grado y su historial (script 071).</summary>
    public interface IAspirantesRepository
    {
        Task<Answer> Anios();
        Task<Answer> Resumen(int aniId);
        Task<Answer> List(int aniId);
        Task<Answer> Find(int id);
        Task<Answer> Historial(int id);
        Task<Answer> Cursos(int cunId);
        Task<Answer> Duplicado(int aniId, string? identidad, string? nombres, string? apellidos, DateTime? fechaNacimiento, int? aspId);
        Task<Answer> Guardar(AspiranteGuardarDTO obj);
        Task<Answer> CambiarEstado(int aspId, string accion, string? motivo, int? aluId, int? usuario);
    }
}
