namespace Gestion.Colegial.Entities.DTOs
{
    /// <summary>Nueva solicitud de la familia. "Usuario" lo pone la API con el usuario firmado.</summary>
    public class PortalSolicitudCrearDTO
    {
        public int? Usuario { get; set; }
        public int Alu_Id { get; set; }
        public string? Tipo { get; set; }
        public string? Asunto { get; set; }
        public string? Detalle { get; set; }
        public DateTime? FechaFalta { get; set; }
    }

    /// <summary>La familia retira una solicitud abierta.</summary>
    public class PortalSolicitudRetirarDTO
    {
        public int? Usuario { get; set; }
        public int Sol_Id { get; set; }
    }

    /// <summary>El colegio cambia el estado de una solicitud.</summary>
    public class PortalBandejaCambiarDTO
    {
        public int? Usuario { get; set; }
        public int Sol_Id { get; set; }
        public string? Estado { get; set; }
        public string? Respuesta { get; set; }
    }

    /// <summary>Invitar, revocar o suspender/reactivar el acceso de un encargado.</summary>
    public class PortalInvitacionAccionDTO
    {
        public int? Usuario { get; set; }
        public int Enc_Id { get; set; }
        public bool Suspender { get; set; }
    }

    /// <summary>Activación pública con el código del enlace (sin usuario de sesión).</summary>
    public class PortalActivarDTO
    {
        public string? Token { get; set; }
        public string? Usu_Name { get; set; }
        public string? Contrasena { get; set; }
    }
}
