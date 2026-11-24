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

    /// <summary>Segundos de bloqueo que faltan (0 = puede intentar).</summary>
    public class PR_tbIntentosLogin_SegundosResult
    {
        public int Segundos { get; set; }
    }

    /// <summary>Filas afectadas por el procedimiento.</summary>
    public class PR_FilasResult
    {
        public int Filas { get; set; }
    }
}
