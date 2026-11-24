using Gestion.Colegial.Entities;
using Gestion.Colegial.Entities.DTOs;

namespace Gestion.Colegial.DataAccess.Interfaces
{
    /// <summary>Portal de padres: lecturas de la familia, solicitudes, bandeja e invitaciones (script 082).</summary>
    public interface IPortalPadresRepository
    {
        Task<Answer> Encargado(int usuId);
        Task<Answer> Hijos(int usuId);
        Task<Answer> PuedeVer(int usuId, int aluId);
        Task<Answer> Notas(int usuId, int aluId, int? anio);
        Task<Answer> Asistencia(int usuId, int aluId, int? anio);
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
        Task<Answer> InvitacionCrear(int usuario, int encId, string tokenHash, int horas);
        Task<Answer> InvitacionRevocar(int usuario, int encId);
        Task<Answer> AccesoCambiar(int usuario, int encId, bool suspender);
        Task<Answer> InvitacionInfo(string tokenHash);
        Task<Answer> InvitacionAceptar(string tokenHash, string usuName, string contrasenaHash);
    }
}
