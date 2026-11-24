namespace Gestion.Colegial.Entities.Entities
{
    /// <summary>Encargado ligado al usuario del portal (script 082).</summary>
    public class PR_Portal_EncargadoResult
    {
        public int Enc_Id { get; set; }
        public string Enc_Nombre { get; set; }
        public string Enc_PrimerNombre { get; set; }
        public string Enc_Correo { get; set; }
        public string Enc_Telefono { get; set; }
    }

    /// <summary>Un hijo del encargado con el resumen de su tarjeta.</summary>
    public class PR_Portal_HijosResult
    {
        public int Alu_Id { get; set; }
        public string Alu_Nombre { get; set; }
        public string Alu_PrimerNombre { get; set; }
        public string Alu_Imagen { get; set; }
        public int? Anio { get; set; }
        public string Nivel { get; set; }
        public string Grado { get; set; }
        public string Seccion { get; set; }
        public string Curso { get; set; }
        public string Parentesco { get; set; }
        public string Estado { get; set; }
        public decimal SaldoPendiente { get; set; }
        public decimal SaldoVencido { get; set; }
        public int Ausencias { get; set; }
        public int Tardanzas { get; set; }
        public int RegistrosAsistencia { get; set; }
        public decimal? PromedioPublicado { get; set; }
        public int SolicitudesAbiertas { get; set; }
    }

    public class PR_Portal_PuedeVerResult
    {
        public bool Puede { get; set; }
    }

    /// <summary>Nota de un parcial publicado.</summary>
    public class PR_Portal_NotasResult
    {
        public int Mat_Id { get; set; }
        public string Mat_Nombre { get; set; }
        public int Sem_Id { get; set; }
        public string Sem_Descripcion { get; set; }
        public int Pac_Id { get; set; }
        public string Pac_Descripcion { get; set; }
        public decimal Nota { get; set; }
        public string Concepto { get; set; }
        public bool Aprueba { get; set; }
        public DateTime? FechaPublicacion { get; set; }
        public decimal? NotaMinima { get; set; }
    }

    public class PR_Portal_AsistenciaResult
    {
        public int Asi_Id { get; set; }
        public DateTime Asi_Fecha { get; set; }
        public string Asi_Estado { get; set; }
        public string Asi_Observacion { get; set; }
        public string Mat_Nombre { get; set; }
        public string HoraInicio { get; set; }
    }

    /// <summary>Solicitud vista por la familia.</summary>
    public class PR_Portal_SolicitudesResult
    {
        public int Sol_Id { get; set; }
        public int Alu_Id { get; set; }
        public string Alu_PrimerNombre { get; set; }
        public string Sol_Tipo { get; set; }
        public string Sol_Asunto { get; set; }
        public string Sol_Detalle { get; set; }
        public DateTime? Sol_FechaFalta { get; set; }
        public string Sol_Estado { get; set; }
        public string Sol_Respuesta { get; set; }
        public DateTime? Sol_FechaAtiende { get; set; }
        public DateTime Sol_FechaRegistra { get; set; }
    }

    /// <summary>Respuesta de las escrituras de solicitudes.</summary>
    public class PR_Portal_SolicitudEscrituraResult
    {
        public int Sol_Id { get; set; }
        public string Sol_Estado { get; set; }
    }

    /// <summary>Fila de la bandeja de solicitudes del colegio.</summary>
    public class PR_Portal_BandejaResult
    {
        public int Sol_Id { get; set; }
        public string Sol_Tipo { get; set; }
        public string Sol_Asunto { get; set; }
        public DateTime? Sol_FechaFalta { get; set; }
        public string Sol_Estado { get; set; }
        public DateTime Sol_FechaRegistra { get; set; }
        public DateTime? Sol_FechaAtiende { get; set; }
        public int Alu_Id { get; set; }
        public string Alu_Nombre { get; set; }
        public string Grado { get; set; }
        public string Seccion { get; set; }
        public int Enc_Id { get; set; }
        public string Enc_Nombre { get; set; }
        public string AtendidoPor { get; set; }
    }

    public class PR_Portal_BandejaResumenResult
    {
        public int? Nuevas { get; set; }
        public int? EnProceso { get; set; }
        public int? AtendidasMes { get; set; }
        public int? RechazadasMes { get; set; }
    }

    /// <summary>Una solicitud completa para atenderla.</summary>
    public class PR_Portal_BandejaFindResult
    {
        public int Sol_Id { get; set; }
        public string Sol_Tipo { get; set; }
        public string Sol_Asunto { get; set; }
        public string Sol_Detalle { get; set; }
        public DateTime? Sol_FechaFalta { get; set; }
        public string Sol_Estado { get; set; }
        public string Sol_Respuesta { get; set; }
        public DateTime Sol_FechaRegistra { get; set; }
        public DateTime? Sol_FechaAtiende { get; set; }
        public int Alu_Id { get; set; }
        public string Alu_Nombre { get; set; }
        public string Grado { get; set; }
        public string Seccion { get; set; }
        public int Enc_Id { get; set; }
        public string Enc_Nombre { get; set; }
        public string Enc_Telefono { get; set; }
        public string Enc_Correo { get; set; }
        public string Parentesco { get; set; }
        public string SolicitadoPor { get; set; }
        public string AtendidoPor { get; set; }
    }

    public class PR_Portal_BandejaHistorialResult
    {
        public int Soh_Id { get; set; }
        public string Soh_EstadoAnterior { get; set; }
        public string Soh_EstadoNuevo { get; set; }
        public string Soh_Comentario { get; set; }
        public DateTime Soh_Fecha { get; set; }
        public string Usu_Name { get; set; }
        public bool EsFamilia { get; set; }
    }

    /// <summary>Encargado con su acceso al portal.</summary>
    public class PR_Portal_InvitacionesListResult
    {
        public int Enc_Id { get; set; }
        public string Enc_Nombre { get; set; }
        public string Enc_Identidad { get; set; }
        public string Enc_Telefono { get; set; }
        public string Enc_Correo { get; set; }
        public int Hijos { get; set; }
        public string HijosNombres { get; set; }
        public int? Usu_Id { get; set; }
        public string Usu_Name { get; set; }
        public bool CuentaActiva { get; set; }
        public int? Inv_Id { get; set; }
        public DateTime? Inv_FechaRegistra { get; set; }
        public DateTime? Inv_Vence { get; set; }
        public string InvitadoPor { get; set; }
        public string InvEstado { get; set; }
        public string EstadoAcceso { get; set; }
    }

    public class PR_Portal_InvitacionesResumenResult
    {
        public int ConHijos { get; set; }
        public int? Activos { get; set; }
        public int? Pendientes { get; set; }
        public int? SinAcceso { get; set; }
    }

    public class PR_Portal_InvitacionCrearResult
    {
        public int Inv_Id { get; set; }
        public DateTime Inv_Vence { get; set; }
        public string Enc_Nombre { get; set; }
    }

    public class PR_Portal_InvitacionInfoResult
    {
        public string Estado { get; set; }
        public string Enc_Nombre { get; set; }
        public string Hijos { get; set; }
        public string UsuarioExistente { get; set; }
        public DateTime? Inv_Vence { get; set; }
    }

    public class PR_Portal_InvitacionAceptarResult
    {
        public int Usu_Id { get; set; }
        public string Usu_Name { get; set; }
    }

    public class PR_Portal_IdResult
    {
        public int Inv_Id { get; set; }
        public int Usu_Id { get; set; }
    }
}
