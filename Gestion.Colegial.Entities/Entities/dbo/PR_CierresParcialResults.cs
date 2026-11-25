namespace Gestion.Colegial.Entities.Entities
{
    /// <summary>Años que se pueden revisar en "Cierre de parciales" (script 075).</summary>
    public class PR_CierresParcial_AniosResult
    {
        public int Anio { get; set; }
        public bool EsActivo { get; set; }
    }

    /// <summary>Estado de un período (semestre × parcial) sin el avance: cuaderno de notas y boletín.</summary>
    public class PR_CierresParcial_PeriodosResult
    {
        public int Anio { get; set; }
        public int Sem_Id { get; set; }
        public int Pac_Id { get; set; }
        public string Parcial { get; set; }
        public string Semestre { get; set; }
        /// <summary>abierto | cerrado</summary>
        public string Estado { get; set; }
        public bool Publicado { get; set; }
        public DateTime? FechaCierre { get; set; }
        public string UsuarioCierre { get; set; }
        public DateTime? FechaPublicacion { get; set; }
        public int NotasPeriodo { get; set; }
    }

    /// <summary>Tablero de "Cierre de parciales": estado, fechas y avance de notas de un período.</summary>
    public class PR_CierresParcial_EstadoResult
    {
        public int Anio { get; set; }
        public int Sem_Id { get; set; }
        public int Pac_Id { get; set; }
        public string Parcial { get; set; }
        public string Semestre { get; set; }
        public string Estado { get; set; }
        public bool Publicado { get; set; }
        public DateTime? FechaInicio { get; set; }
        public DateTime? FechaLimite { get; set; }
        public DateTime? SemestreInicio { get; set; }
        public DateTime? SemestreFin { get; set; }
        public bool SemestreVigente { get; set; }
        public bool LimiteVencido { get; set; }
        public DateTime? FechaCierre { get; set; }
        public string UsuarioCierre { get; set; }
        public DateTime? FechaPublicacion { get; set; }
        public string UsuarioPublicacion { get; set; }
        public int Esperadas { get; set; }
        public int Cargadas { get; set; }
        public int Faltantes { get; set; }
        public int SeccionesConFaltantes { get; set; }
        public int MateriasConFaltantes { get; set; }
        public int NotasPeriodo { get; set; }
        public int SeccionesSinHorario { get; set; }
        public int AlumnosSinHorario { get; set; }
    }

    /// <summary>Notas faltantes de un período por sección, materia y docente.</summary>
    public class PR_CierresParcial_FaltantesResult
    {
        public int Cur_Id { get; set; }
        public int Cun_Id { get; set; }
        public int Sec_Id { get; set; }
        public int Mda_Id { get; set; }
        public int Mat_Id { get; set; }
        public string Nivel { get; set; }
        public string Carrera { get; set; }
        public string Grado { get; set; }
        public int GradoOrden { get; set; }
        public string Seccion { get; set; }
        public string Modalidad { get; set; }
        public string Materia { get; set; }
        public string Docentes { get; set; }
        public int Alumnos { get; set; }
        public int Cargadas { get; set; }
        public int Faltan { get; set; }
        public decimal? Porcentaje { get; set; }
    }

    /// <summary>Una acción del historial (cerrar, reabrir, publicar, despublicar, fechas).</summary>
    public class PR_CierresParcial_HistorialResult
    {
        public int Cph_Id { get; set; }
        public int Anio { get; set; }
        public int Sem_Id { get; set; }
        public int Pac_Id { get; set; }
        public string Parcial { get; set; }
        public string Semestre { get; set; }
        public string Accion { get; set; }
        public string Motivo { get; set; }
        public int? Esperadas { get; set; }
        public int? Cargadas { get; set; }
        public int? Faltantes { get; set; }
        public string Usuario { get; set; }
        public DateTime Fecha { get; set; }
    }

    /// <summary>Respuesta de toda escritura de cierre.</summary>
    public class PR_CierresParcial_EscrituraResult
    {
        public int Cpa_Id { get; set; }
        public string Estado { get; set; }
        public bool Publicado { get; set; }
    }

    /// <summary>Respuesta de app.PR_tbNotas_Update (1 = guardó, 0 = falló).</summary>
    public class PR_tbNotas_UpdateResult
    {
        public int CodeResult { get; set; }
    }
}
