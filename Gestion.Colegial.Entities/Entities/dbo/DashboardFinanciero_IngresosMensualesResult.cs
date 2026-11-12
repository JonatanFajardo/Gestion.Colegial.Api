namespace Gestion.Colegial.Entities.Entities
{
    public partial class DashboardFinanciero_IngresosMensualesResult
    {
        public int? Mes { get; set; }
        public int? Anio { get; set; }
        public string? EtiquetaMes { get; set; }
        public decimal? Facturado { get; set; }
        public decimal? Cobrado { get; set; }
        public decimal? Pendiente { get; set; }
    }
}
