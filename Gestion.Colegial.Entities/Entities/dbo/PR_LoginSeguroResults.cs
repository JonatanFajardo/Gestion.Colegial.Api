namespace Gestion.Colegial.Entities.Entities
{
    /// <summary>seguridad.PR_tbUsuarios_DatosLogin: datos del usuario y su huella guardada.</summary>
    public class PR_tbUsuarios_DatosLoginResult
    {
        public int Usu_Id { get; set; }
        public string? Usu_Name { get; set; }
        public int Emp_Id { get; set; }
        public int Rol_Id { get; set; }
        public string? Rol_Nombre { get; set; }
        public string? Usu_Contrasena { get; set; }
        /// <summary>1 = activo, no suspendido y no eliminado.</summary>
        public int Habilitado { get; set; }
    }

    /// <summary>
    /// seguridad.PR_tbIntentosLogin_Reservar. Permitido = 0: bloqueado (Segundos = lo que falta).
    /// Permitido = 1: se puede revisar la contraseña; Segundos &gt; 0 si este intento inició un bloqueo.
    /// </summary>
    public class PR_tbIntentosLogin_ReservarResult
    {
        public int Permitido { get; set; }
        public int Segundos { get; set; }
        public int BloqueoUsuario { get; set; }
        public int BloqueoIp { get; set; }
    }

    /// <summary>Filas afectadas por el procedimiento.</summary>
    public class PR_FilasResult
    {
        public int Filas { get; set; }
    }
}
