namespace Gestion.Colegial.Entities.Entities
{
    /// <summary>Año lectivo para el selector de la lista de espera (script 071).</summary>
    public class PR_tbAspirantes_AniosResult
    {
        public int Ani_Id { get; set; }
        public int Ani_Anio { get; set; }
        public string? Ani_Nombre { get; set; }
        public int Ani_Estado { get; set; }
        public bool EsActivo { get; set; }
        public bool EsPorDefecto { get; set; }
        public bool AdmiteRegistro { get; set; }
        public int Abiertos { get; set; }
    }

    /// <summary>Cupo y demanda de un grado en un año. Cupo y Libres NULL = cupo sin definir.</summary>
    public class PR_tbAspirantes_ResumenResult
    {
        public int Niv_Id { get; set; }
        public string? Niv_Descripcion { get; set; }
        public int Cun_Id { get; set; }
        public string? Cun_Descripcion { get; set; }
        public int Cun_Orden { get; set; }
        public int Secciones { get; set; }
        public int SeccionesConCupo { get; set; }
        public int? Cupo { get; set; }
        public int Matriculados { get; set; }
        public int Ofertas { get; set; }
        public bool CupoDefinido { get; set; }
        public int? Libres { get; set; }
        public int EnEspera { get; set; }
        public int MatriculadosLista { get; set; }
        public int Cerrados { get; set; }
        public int? SiguienteId { get; set; }
        public string? SiguienteNombre { get; set; }
    }

    /// <summary>Un aspirante en la lista. PosicionCola solo para los que están en espera.</summary>
    public class PR_tbAspirantes_ListResult
    {
        public int Asp_Id { get; set; }
        public int Ani_Id { get; set; }
        public string? Asp_Nombres { get; set; }
        public string? Asp_Apellidos { get; set; }
        public string? Aspirante { get; set; }
        public string? Asp_Identidad { get; set; }
        public DateTime Asp_FechaNacimiento { get; set; }
        public int? Edad { get; set; }
        public string? Asp_Sexo { get; set; }
        public string? Asp_EscuelaProcedencia { get; set; }
        public string? Asp_EncargadoNombre { get; set; }
        public int? Par_Id { get; set; }
        public string? Par_Descripcion { get; set; }
        public string? Asp_EncargadoTelefono { get; set; }
        public string? Asp_EncargadoCorreo { get; set; }
        public int Niv_Id { get; set; }
        public string? Niv_Descripcion { get; set; }
        public int Cun_Id { get; set; }
        public string? Cun_Descripcion { get; set; }
        public int? Mda_Id { get; set; }
        public string? Mda_Descripcion { get; set; }
        public int? Cur_Id { get; set; }
        public string? Cur_Nombre { get; set; }
        public DateTime Asp_FechaSolicitud { get; set; }
        public string? Asp_Estado { get; set; }
        public int Asp_Prioridad { get; set; }
        public string? Asp_MotivoPrioridad { get; set; }
        public int Asp_Posicion { get; set; }
        public long? PosicionCola { get; set; }
        public bool EsSiguiente { get; set; }
        public bool CupoDefinido { get; set; }
        public int? Libres { get; set; }
        public bool PuedeOfrecer { get; set; }
        public DateTime? Asp_FechaOferta { get; set; }
        public DateTime? Asp_FechaDecision { get; set; }
        public string? Asp_MotivoDecision { get; set; }
        public int? Alu_Id { get; set; }
        public int Cun_Orden { get; set; }
    }

    /// <summary>Un aspirante completo con su lugar en la cola y el cupo de su grado.</summary>
    public class PR_tbAspirantes_FindResult
    {
        public int Asp_Id { get; set; }
        public int Ani_Id { get; set; }
        public string? Ani_Nombre { get; set; }
        public bool EsAnioActivo { get; set; }
        public string? Asp_Nombres { get; set; }
        public string? Asp_Apellidos { get; set; }
        public string? Aspirante { get; set; }
        public string? Asp_Identidad { get; set; }
        public DateTime Asp_FechaNacimiento { get; set; }
        public int? Edad { get; set; }
        public string? Asp_Sexo { get; set; }
        public string? Asp_EscuelaProcedencia { get; set; }
        public string? Asp_EncargadoNombre { get; set; }
        public string? Asp_EncargadoIdentidad { get; set; }
        public int? Par_Id { get; set; }
        public string? Par_Descripcion { get; set; }
        public string? Asp_EncargadoTelefono { get; set; }
        public string? Asp_EncargadoCorreo { get; set; }
        public int Niv_Id { get; set; }
        public string? Niv_Descripcion { get; set; }
        public int Cun_Id { get; set; }
        public string? Cun_Descripcion { get; set; }
        public int? Mda_Id { get; set; }
        public string? Mda_Descripcion { get; set; }
        public int? Cur_Id { get; set; }
        public string? Cur_Nombre { get; set; }
        public DateTime Asp_FechaSolicitud { get; set; }
        public string? Asp_Estado { get; set; }
        public int Asp_Prioridad { get; set; }
        public string? Asp_MotivoPrioridad { get; set; }
        public int Asp_Posicion { get; set; }
        public long? PosicionCola { get; set; }
        public int EnCola { get; set; }
        public int? SiguienteId { get; set; }
        public string? SiguienteNombre { get; set; }
        public int Secciones { get; set; }
        public int SeccionesConCupo { get; set; }
        public int? Cupo { get; set; }
        public int Matriculados { get; set; }
        public int Ofertas { get; set; }
        public bool CupoDefinido { get; set; }
        public int? Libres { get; set; }
        public bool? CupoModalidadDefinido { get; set; }
        public int? LibresModalidad { get; set; }
        public bool PuedeOfrecer { get; set; }
        public string? Asp_MotivoDecision { get; set; }
        public DateTime? Asp_FechaOferta { get; set; }
        public string? UsuarioOferta { get; set; }
        public DateTime? Asp_FechaDecision { get; set; }
        public string? UsuarioDecision { get; set; }
        public int? Alu_Id { get; set; }
        public string? Asp_Notas { get; set; }
        public DateTime Asp_FechaRegistra { get; set; }
        public string? UsuarioRegistra { get; set; }
        public DateTime? Asp_FechaModifica { get; set; }
    }

    /// <summary>Un paso de la línea de tiempo. EstadoAnterior NULL = se registró.</summary>
    public class PR_tbAspirantesHistorial_ListResult
    {
        public int Ash_Id { get; set; }
        public int Asp_Id { get; set; }
        public string? Ash_EstadoAnterior { get; set; }
        public string? Ash_EstadoNuevo { get; set; }
        public string? Ash_Motivo { get; set; }
        public int? Ash_Usuario { get; set; }
        public string? Usuario { get; set; }
        public DateTime Ash_Fecha { get; set; }
    }

    /// <summary>Revisión en vivo: aspirante abierto igual en el año y alumno con la misma identidad.</summary>
    public class PR_tbAspirantes_DuplicadoResult
    {
        public int? AspiranteId { get; set; }
        public string? AspiranteNombre { get; set; }
        public string? AspiranteEstado { get; set; }
        public string? AspiranteGrado { get; set; }
        public int? AlumnoId { get; set; }
        public string? AlumnoNombre { get; set; }
        public bool AlumnoMatriculadoEnAnio { get; set; }
    }

    public class PR_tbAspirantes_CursosResult
    {
        public int Cur_Id { get; set; }
        public string? Cur_Nombre { get; set; }
    }

    public class PR_tbAspirantes_GuardarResult
    {
        public int Asp_Id { get; set; }
        public int Asp_Posicion { get; set; }
        public string? Asp_Estado { get; set; }
        public long? PosicionCola { get; set; }
        public int EnCola { get; set; }
        public string? Cun_Descripcion { get; set; }
        public string? Aviso { get; set; }
    }

    public class PR_tbAspirantes_CambiarEstadoResult
    {
        public int Asp_Id { get; set; }
        public string? Asp_Estado { get; set; }
        public int Asp_Posicion { get; set; }
        public int? Alu_Id { get; set; }
        public string? Aviso { get; set; }
    }
}
