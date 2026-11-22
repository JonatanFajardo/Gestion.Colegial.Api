namespace Gestion.Colegial.Entities.Entities
{
    /// <summary>Un plan en el directorio (script 072). Solo los planes que la persona puede leer.</summary>
    public class PR_tbPlanesApoyo_ListResult
    {
        public int Apo_Id { get; set; }
        public int Alu_Id { get; set; }
        public string Alumno { get; set; }
        public string Identidad { get; set; }
        public string Foto { get; set; }
        public int? Niv_Id { get; set; }
        public string Nivel { get; set; }
        public int? Cun_Id { get; set; }
        public string Grado { get; set; }
        public int? Sec_Id { get; set; }
        public string Seccion { get; set; }
        public string Apo_Categoria { get; set; }
        public string Apo_Titulo { get; set; }
        public string Apo_Estado { get; set; }
        public bool Apo_EsConfidencial { get; set; }
        public DateTime Apo_FechaInicio { get; set; }
        public DateTime? Apo_FechaRevision { get; set; }
        public DateTime? Apo_FechaFin { get; set; }
        public int? Usu_IdResponsable { get; set; }
        public string Responsable { get; set; }
        public int PasosTotal { get; set; }
        public int PasosHechos { get; set; }
        public int PasosAtrasados { get; set; }
        public int MisPasosPendientes { get; set; }
        public bool RevisionVencida { get; set; }
        public bool EsResponsable { get; set; }
        public bool TienePasos { get; set; }
        public DateTime Apo_FechaRegistra { get; set; }
    }

    /// <summary>Indicadores del directorio (mismas reglas de lectura que el listado).</summary>
    public class PR_tbPlanesApoyo_ResumenResult
    {
        public int Activos { get; set; }
        public int Abiertos { get; set; }
        public int RevisionVencida { get; set; }
        public int PasosAtrasados { get; set; }
        public int CompletadosAnio { get; set; }
        public string AnioNombre { get; set; }
    }

    /// <summary>Un plan completo. EsResponsable / EsCreador = respecto de quien consulta.</summary>
    public class PR_tbPlanesApoyo_FindResult
    {
        public int Apo_Id { get; set; }
        public int Alu_Id { get; set; }
        public string Alumno { get; set; }
        public string Identidad { get; set; }
        public string Foto { get; set; }
        public string Nivel { get; set; }
        public string Grado { get; set; }
        public string Seccion { get; set; }
        public string Curso { get; set; }
        public int? Ani_Id { get; set; }
        public string Ani_Nombre { get; set; }
        public string Apo_Categoria { get; set; }
        public string Apo_Titulo { get; set; }
        public string Apo_Resumen { get; set; }
        public string Apo_Estado { get; set; }
        public bool Apo_EsConfidencial { get; set; }
        public DateTime Apo_FechaInicio { get; set; }
        public DateTime? Apo_FechaRevision { get; set; }
        public DateTime? Apo_FechaFin { get; set; }
        public int Apo_Version { get; set; }
        public int? Usu_IdResponsable { get; set; }
        public string Responsable { get; set; }
        public int? Apo_UsuarioRegistra { get; set; }
        public string Creador { get; set; }
        public DateTime Apo_FechaRegistra { get; set; }
        public DateTime? Apo_FechaModifica { get; set; }
        public int PasosTotal { get; set; }
        public int PasosHechos { get; set; }
        public bool RevisionVencida { get; set; }
        public bool EsResponsable { get; set; }
        public bool EsCreador { get; set; }
    }

    public class PR_tbPlanesApoyoAcciones_ListResult
    {
        public int Apa_Id { get; set; }
        public string Apa_Descripcion { get; set; }
        public DateTime? Apa_FechaLimite { get; set; }
        public DateTime? Apa_FechaHecha { get; set; }
        public int? Usu_IdResponsable { get; set; }
        public string Responsable { get; set; }
        public string HechaPor { get; set; }
        public bool Atrasado { get; set; }
        public bool EsMio { get; set; }
    }

    public class PR_tbPlanesApoyoNotas_ListResult
    {
        public int Apn_Id { get; set; }
        public string Apn_Texto { get; set; }
        public DateTime Apn_Fecha { get; set; }
        public int? Apn_Usuario { get; set; }
        public string Usuario { get; set; }
    }

    public class PR_tbPlanesApoyoEstados_ListResult
    {
        public int Ape_Id { get; set; }
        public string Ape_De { get; set; }
        public string Ape_A { get; set; }
        public string Ape_Motivo { get; set; }
        public DateTime Ape_Fecha { get; set; }
        public string Usuario { get; set; }
    }

    /// <summary>Usuario que puede ser responsable (admin, director o Docente activo).</summary>
    public class PR_tbPlanesApoyo_UsuariosResult
    {
        public int Usu_Id { get; set; }
        public string Usuario { get; set; }
        public string Nombre { get; set; }
        public string Rol { get; set; }
    }

    public class PR_tbPlanesApoyo_AlumnosResult
    {
        public int Alu_Id { get; set; }
        public string Nombre { get; set; }
        public string Identidad { get; set; }
        public string Nivel { get; set; }
        public string Ubicacion { get; set; }
    }

    public class PR_tbPlanesApoyo_SeccionesResult
    {
        public int Sec_Id { get; set; }
        public string Sec_Descripcion { get; set; }
    }

    /// <summary>Plan abierto de un alumno (para "Crear plan" / "Ver plan" y el aviso de duplicado).</summary>
    public class PR_tbPlanesApoyo_AbiertosDeAlumnosResult
    {
        public int Alu_Id { get; set; }
        public int Apo_Id { get; set; }
        public string Apo_Titulo { get; set; }
        public string Apo_Estado { get; set; }
        public string Apo_Categoria { get; set; }
        public DateTime? Apo_FechaRevision { get; set; }
    }

    /// <summary>Resultado de crear, editar, cambiar de estado o eliminar un plan.</summary>
    public class PR_tbPlanesApoyo_EscrituraResult
    {
        public int Apo_Id { get; set; }
        public string Apo_Estado { get; set; }
        public int Apo_Version { get; set; }
    }

    public class PR_tbPlanesApoyoAcciones_EscrituraResult
    {
        public int Apa_Id { get; set; }
    }

    public class PR_tbPlanesApoyoNotas_AgregarResult
    {
        public int Apn_Id { get; set; }
    }
}
