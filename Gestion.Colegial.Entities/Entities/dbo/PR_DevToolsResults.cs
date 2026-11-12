namespace Gestion.Colegial.Entities.Entities
{
    public class PR_ActualizarFechas_DetectarResult
    {
        public int AnioActual { get; set; }
        public int AnioObjetivo { get; set; }
        public int Delta { get; set; }
        public bool Sincronizado { get; set; }
    }

    public class PR_ActualizarFechas_PasoResult
    {
        public string Tabla { get; set; }
        public int RowsAffected { get; set; }
        public int DurationMs { get; set; }
        public bool Skipped { get; set; }
    }

    public class PR_DevTools_EstadoBDResult
    {
        public int TotalAlumnos { get; set; }
        public int TotalEmpleados { get; set; }
        public int TotalUsuarios { get; set; }
        public int TotalRoles { get; set; }
        public int TotalPantallas { get; set; }
        public int SesionesActivas { get; set; }
        public int TotalPagos { get; set; }
        public decimal MontoPagadoAnioActual { get; set; }
        public int CuentasPendientes { get; set; }
        public int? AnioActualData { get; set; }
        public int AnioActualSistema { get; set; }
    }

    public class PR_DevTools_RolPantallaResult
    {
        public int Rol_Id { get; set; }
        public string Rol_Descripcion { get; set; }
        public int CantidadPantallas { get; set; }
    }
}
