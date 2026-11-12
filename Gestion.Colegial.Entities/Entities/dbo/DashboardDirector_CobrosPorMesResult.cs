namespace Gestion.Colegial.Entities.Entities
{
    public partial class DashboardDirector_CobrosPorMesResult
    {
        public int Mes { get; set; }
        public int Anio { get; set; }
        public decimal TotalCobrado { get; set; }
        public decimal TotalPendiente { get; set; }
    }
}
