using Gestion.Colegial.Entities;
using Gestion.Colegial.Entities.DTOs;

namespace Gestion.Colegial.DataAccess.Interfaces
{
    /// <summary>Calendario escolar: días del calendario, su "Para quién" y los cierres.</summary>
    public interface IEventosCalendarioRepository
    {
        Task<Answer> ListRango(DateTime desde, DateTime hasta, bool incluirBorradores, bool verTodo, int? empId, int? rolId);
        Task<Answer> Find(int id, bool verTodo, int? empId, int? rolId);
        Task<Answer> Audiencia(int id);
        Task<Answer> Borradores();
        Task<Answer> CierreEnFecha(DateTime fecha, int? seaId, int? horId);
        Task<Answer> Proximos(DateTime? hoy, int dias, bool verTodo, int? empId, int? rolId, int limite);
        Task<Answer> ParaAlumno(int aluId, DateTime desde, DateTime hasta);
        Task<Answer> SeccionesAudiencia(DateTime? fecha, int? eveId);
        Task<Answer> RolesAudiencia();
        Task<Answer> BuscarPersonas(string texto, int limite);
        Task<Answer> ClavesOrigen(string prefijo);
        Task<Answer> Guardar(EventoCalendarioGuardarDTO obj);
        Task<Answer> Publicar(int id, bool publicar, int? usuario);
        Task<Answer> Eliminar(int id, int? usuario);
    }
}
