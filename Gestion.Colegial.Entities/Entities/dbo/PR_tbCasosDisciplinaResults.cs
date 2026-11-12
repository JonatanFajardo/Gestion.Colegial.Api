namespace Gestion.Colegial.Entities.Entities
{
    /// <summary>Un caso en el listado (script 062). TotalFilas = total con los filtros, para paginar.</summary>
    public class PR_tbCasosDisciplina_ListResult
    {
        public int Cas_Id { get; set; }
        public string Cas_Referencia { get; set; }
        public string Cas_Tipo { get; set; }
        public string Cas_Estado { get; set; }
        public bool Cas_EsReservado { get; set; }
        public string Cas_Resumen { get; set; }
        public string Cas_Lugar { get; set; }
        public DateTime Cas_FechaOcurrio { get; set; }
        public int? Emp_IdAtiende { get; set; }
        public string Atiende { get; set; }
        public int Personas { get; set; }
        public int TotalFilas { get; set; }
    }

    public class PR_tbCasosDisciplina_AbiertosResult
    {
        public int Abiertos { get; set; }
    }

    /// <summary>Un caso completo. EsDeLaPersona = quien consulta lo reportó o lo atiende.</summary>
    public class PR_tbCasosDisciplina_FindResult
    {
        public int Cas_Id { get; set; }
        public string Cas_Referencia { get; set; }
        public string Cas_Tipo { get; set; }
        public string Cas_Estado { get; set; }
        public bool Cas_EsReservado { get; set; }
        public string Cas_Resumen { get; set; }
        public string Cas_Descripcion { get; set; }
        public string Cas_Lugar { get; set; }
        public DateTime Cas_FechaOcurrio { get; set; }
        public DateTime Cas_FechaRegistra { get; set; }
        public int? Ani_Id { get; set; }
        public string Ani_Nombre { get; set; }
        public int? Pan_Id { get; set; }
        public string Pan_Nombre { get; set; }
        public int? Cas_UsuarioReporta { get; set; }
        public string Reporta { get; set; }
        public int? Emp_IdAtiende { get; set; }
        public string Atiende { get; set; }
        public int Pendientes { get; set; }
        public bool EsDeLaPersona { get; set; }
    }

    public class PR_tbCasosDisciplinaPersonas_ListResult
    {
        public int Cpe_Id { get; set; }
        public int? Alu_Id { get; set; }
        public int? Emp_Id { get; set; }
        public string Cpe_Papel { get; set; }
        public string Cpe_Nota { get; set; }
        public string Nombre { get; set; }
        public string Identidad { get; set; }
        public string Ubicacion { get; set; }
    }

    public class PR_tbCasosDisciplinaAcciones_ListResult
    {
        public int Cac_Id { get; set; }
        public string Cac_Tipo { get; set; }
        public string Cac_Descripcion { get; set; }
        public DateTime? Cac_FechaLimite { get; set; }
        public DateTime? Cac_FechaHecha { get; set; }
        public int? Emp_IdResponsable { get; set; }
        public string Responsable { get; set; }
    }

    public class PR_tbCasosDisciplinaEstados_ListResult
    {
        public int Ces_Id { get; set; }
        public string Ces_De { get; set; }
        public string Ces_A { get; set; }
        public string Ces_Motivo { get; set; }
        public DateTime Ces_Fecha { get; set; }
        public string Usuario { get; set; }
    }

    public class PR_tbCasosDisciplinaNotas_ListResult
    {
        public int Cno_Id { get; set; }
        public string Cno_Texto { get; set; }
        public bool Cno_EsPrivada { get; set; }
        public DateTime Cno_Fecha { get; set; }
        public string Usuario { get; set; }
    }

    /// <summary>Alumno que se puede nombrar en un caso.</summary>
    public class PR_tbCasosDisciplina_AlumnosResult
    {
        public int Alu_Id { get; set; }
        public string Nombre { get; set; }
        public string Identidad { get; set; }
        public string Ubicacion { get; set; }
    }

    /// <summary>Empleado que puede atender un caso o ser responsable de una acción.</summary>
    public class PR_tbCasosDisciplina_EmpleadosResult
    {
        public int Emp_Id { get; set; }
        public string Nombre { get; set; }
        public string Cargo { get; set; }
    }

    public class PR_tbCasosDisciplina_RegistrarResult
    {
        public int Cas_Id { get; set; }
        public string Cas_Referencia { get; set; }
    }

    public class PR_tbCasosDisciplina_CambiarEstadoResult
    {
        public int Cas_Id { get; set; }
        public string Cas_Estado { get; set; }
    }

    public class PR_tbCasosDisciplinaAcciones_AgregarResult
    {
        public int Cac_Id { get; set; }
    }

    public class PR_tbCasosDisciplinaNotas_AgregarResult
    {
        public int Cno_Id { get; set; }
    }
}
