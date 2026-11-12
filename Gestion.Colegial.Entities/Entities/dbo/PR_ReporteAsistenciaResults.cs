namespace Gestion.Colegial.Entities.Entities
{
    /// <summary>Año lectivo que contiene una fecha (script 063).</summary>
    public class PR_ReporteAsistencia_AnioResult
    {
        public int Ani_Id { get; set; }
        public string? Ani_Nombre { get; set; }
        public DateTime Ani_FechaInicio { get; set; }
        public DateTime Ani_FechaFin { get; set; }
    }

    /// <summary>Período (parcial) del año lectivo.</summary>
    public class PR_ReporteAsistencia_PeriodosResult
    {
        public int Pan_Id { get; set; }
        public string? Pan_Nombre { get; set; }
        public DateTime Pan_FechaInicio { get; set; }
        public DateTime Pan_FechaFin { get; set; }
    }

    /// <summary>Sección del año con su nivel y grado, para armar los filtros en cascada.</summary>
    public class PR_ReporteAsistencia_FiltrosResult
    {
        public int Sea_Id { get; set; }
        public string? Seccion { get; set; }
        public int Niv_Id { get; set; }
        public string? Nivel { get; set; }
        public int Cun_Id { get; set; }
        public string? Grado { get; set; }
    }

    /// <summary>Resumen de asistencia de una sección en el rango.</summary>
    public class PR_ReporteAsistencia_SeccionesResult
    {
        public int Sea_Id { get; set; }
        public string? Seccion { get; set; }
        public string? Nivel { get; set; }
        public string? Grado { get; set; }
        public int Alumnos { get; set; }
        public int DiasClase { get; set; }
        public int DiasConRegistro { get; set; }
        public int Presentes { get; set; }
        public int Tardanzas { get; set; }
        public int Ausentes { get; set; }
        public int Justificados { get; set; }
        public decimal? PorcAsistencia { get; set; }
        public int AlumnosEnRiesgo { get; set; }
    }

    /// <summary>Datos de cabecera de una sección.</summary>
    public class PR_ReporteAsistencia_SeccionInfoResult
    {
        public int Sea_Id { get; set; }
        public int Ani_Id { get; set; }
        public string? Seccion { get; set; }
        public string? Nivel { get; set; }
        public string? Grado { get; set; }
        public string? Guia { get; set; }
    }

    /// <summary>Resumen de asistencia de un alumno en el rango.</summary>
    public class PR_ReporteAsistencia_AlumnosResult
    {
        public int Alu_Id { get; set; }
        public string? NombreAlumno { get; set; }
        public string? Identidad { get; set; }
        public int Presentes { get; set; }
        public int Tardanzas { get; set; }
        public int Ausentes { get; set; }
        public int Justificados { get; set; }
        public int DiasRegistrados { get; set; }
        public decimal? PorcAsistencia { get; set; }
        public bool EnRiesgo { get; set; }
        public DateTime? UltimaAusencia { get; set; }
    }

    /// <summary>Día hábil del rango: si es cierre (feriado, etc.) y si tiene registro.</summary>
    public class PR_ReporteAsistencia_DiasResult
    {
        public DateTime Fecha { get; set; }
        public bool EsCierre { get; set; }
        public string? Motivo { get; set; }
        public bool ConRegistro { get; set; }
    }

    /// <summary>Estado del día de un alumno: P presente, T tardanza, A ausente, J justificado.</summary>
    public class PR_ReporteAsistencia_PlanillaResult
    {
        public int Alu_Id { get; set; }
        public DateTime Fecha { get; set; }
        public string? Estado { get; set; }
    }
}
