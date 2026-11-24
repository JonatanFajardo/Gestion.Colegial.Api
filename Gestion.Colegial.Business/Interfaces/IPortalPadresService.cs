using Gestion.Colegial.Entities;
using Gestion.Colegial.Entities.DTOs;

namespace Gestion.Colegial.Business.Interfaces
{
    /// <summary>Portal de padres: lo que ve la familia, sus solicitudes, la bandeja del colegio y las invitaciones.</summary>
    public interface IPortalPadresService
    {
        Task<Answer> Encargado(int usuId);
        Task<Answer> Hijos(int usuId);
        Task<Answer> Notas(int usuId, int aluId, int? anio);
        Task<Answer> Asistencia(int usuId, int aluId, int? anio);
        Task<Answer> Cuenta(int usuId, int aluId, int? anio);
        Task<Answer> Calendario(int usuId, int aluId, DateTime desde, DateTime hasta);
        Task<Answer> Anuncios();
        Task<Answer> Solicitudes(int usuId, int? aluId);
        Task<Answer> SolicitudCrear(PortalSolicitudCrearDTO obj);
        Task<Answer> SolicitudRetirar(PortalSolicitudRetirarDTO obj);

        Task<Answer> Bandeja(string? estado, string? tipo, string? texto);
        Task<Answer> BandejaResumen();
        Task<Answer> BandejaFind(int solId);
        Task<Answer> BandejaHistorial(int solId);
        Task<Answer> BandejaCambiar(PortalBandejaCambiarDTO obj);

        Task<Answer> Invitaciones(string? texto, string? estado, bool soloConHijos);
        Task<Answer> InvitacionesResumen();
        /// <summary>Crea la invitación; en Data va (resultado, código en claro). El código solo se entrega aquí.</summary>
        Task<(Answer Answer, string? Codigo)> InvitacionCrear(PortalInvitacionAccionDTO obj);
        Task<Answer> InvitacionRevocar(PortalInvitacionAccionDTO obj);
        Task<Answer> AccesoCambiar(PortalInvitacionAccionDTO obj);
        Task<Answer> InvitacionInfo(string? codigo);
        Task<Answer> InvitacionAceptar(PortalActivarDTO obj);
    }
}
