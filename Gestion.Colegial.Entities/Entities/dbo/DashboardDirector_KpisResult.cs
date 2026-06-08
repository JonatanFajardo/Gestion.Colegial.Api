namespace Gestion.Colegial.Entities.Entities
{
    public partial class DashboardDirector_KpisResult
    {
        public int TotalAlumnos { get; set; }
        public int TotalEmpleados { get; set; }
        public decimal TotalCobradoMes { get; set; }
        public decimal TotalDeudaPendiente { get; set; }
        public int CuentasVencidas { get; set; }
        public decimal PromedioGeneral { get; set; }
        public int AlumnosEnRiesgo { get; set; }
        public int AlumnosPresentesHoy { get; set; }
        public int AlumnosAusentesHoy { get; set; }
    }
}
