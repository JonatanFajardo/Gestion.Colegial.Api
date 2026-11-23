using Gestion.Colegial.Entities;
using Gestion.Colegial.Entities.DTOs;

namespace Gestion.Colegial.DataAccess.Interfaces
{
    /// <summary>Temario y avance del programa (script 074).</summary>
    public interface ITemariosRepository
    {
        Task<Answer> List(int usuId);
        Task<Answer> Find(int id, int usuId);
        Task<Answer> Temas(int id, int usuId);
        Task<Answer> Grupos(int id, int usuId);
        Task<Answer> Avance(int id, int usuId);
        Task<Answer> Resumen(int usuId, int? anio, int? semId);
        Task<Answer> SinTemario(int usuId, int? anio, int? semId);
        Task<Answer> Opciones(int usuId, string tipo, int? nivId, int? cunId, int? curId, int? anio);
        Task<Answer> TemasDeHorario(int horId, int semana, int usuId);
        Task<Answer> Crear(TemarioGuardarDTO obj);
        Task<Answer> Editar(TemarioGuardarDTO obj);
        Task<Answer> Eliminar(TemarioEliminarDTO obj);
        Task<Answer> Copiar(TemarioCopiarDTO obj);
        Task<Answer> GuardarTema(TemarioTemaDTO obj);
        Task<Answer> MoverTema(TemarioTemaAccionDTO obj);
        Task<Answer> QuitarTema(TemarioTemaAccionDTO obj);
        Task<Answer> MarcarAvance(TemarioAvanceDTO obj);
        Task<Answer> QuitarAvance(TemarioAvanceDTO obj);
    }
}
