namespace Gestion.Colegial.Entities.Entities
{
    // Centro de reportes (script 081). Los nombres de las propiedades son las columnas que
    // devuelven los procedimientos app.PR_CentroReportes_* y app.PR_tbReportesGenerados_*.

    /// <summary>Alumno de la lista de clase de una sección.</summary>
    public class PR_CentroReportes_ListaClaseResult
    {
        public string? Nivel { get; set; }
        public string? Grado { get; set; }
        public string? Seccion { get; set; }
        public int Numero { get; set; }
        public int Alu_Id { get; set; }
        public string? Alumno { get; set; }
        public string? Identidad { get; set; }
        public string? Sexo { get; set; }
        public DateTime? FechaNacimiento { get; set; }
        public int? Edad { get; set; }
        public string? Telefono { get; set; }
        public string? EstadoMatricula { get; set; }
    }

    /// <summary>Saldo de un alumno del año.</summary>
    public class PR_CentroReportes_SaldosAlumnoResult
    {
        public string? Nivel { get; set; }
        public string? Grado { get; set; }
        public string? Seccion { get; set; }
        public int Alu_Id { get; set; }
        public string? Alumno { get; set; }
        public string? Identidad { get; set; }
        public string? Telefono { get; set; }
        public decimal Cargado { get; set; }
        public decimal Pagado { get; set; }
        public decimal Saldo { get; set; }
        public decimal Vencido { get; set; }
        public int CargosVencidos { get; set; }
        public DateTime? UltimoPago { get; set; }
    }

    /// <summary>Dinero cobrado por concepto y forma de pago.</summary>
    public class PR_CentroReportes_IngresosConceptoResult
    {
        public string? Concepto { get; set; }
        public string? FormaPago { get; set; }
        public int Pagos { get; set; }
        public int Alumnos { get; set; }
        public decimal Monto { get; set; }
    }

    /// <summary>Resumen de asistencia de un empleado en el rango.</summary>
    public class PR_CentroReportes_AsistenciaPersonalResult
    {
        public int Emp_Id { get; set; }
        public string? Codigo { get; set; }
        public string? Empleado { get; set; }
        public string? Cargo { get; set; }
        public int Registros { get; set; }
        public int Presente { get; set; }
        public int Tardanza { get; set; }
        public int Ausente { get; set; }
        public int Permiso { get; set; }
        public decimal? PorcAsistencia { get; set; }
        public DateTime? UltimaAusencia { get; set; }
    }

    /// <summary>Id del reporte generado recién registrado.</summary>
    public class PR_tbReportesGenerados_RegistrarResult
    {
        public int Rge_Id { get; set; }
    }

    /// <summary>Reporte generado por el usuario (para "Recientes").</summary>
    public class PR_tbReportesGenerados_RecientesResult
    {
        public int Rge_Id { get; set; }
        public string? Rge_Clave { get; set; }
        public string? Rge_Titulo { get; set; }
        public string? Rge_Parametros { get; set; }
        public string? Rge_Resumen { get; set; }
        public string? Rge_Estado { get; set; }
        public int? Rge_Filas { get; set; }
        public string? Rge_Error { get; set; }
        public DateTime Rge_Fecha { get; set; }
        public int Veces { get; set; }
    }
}
