using System;

namespace Gestion.Colegial.Entities.Entities
{
    public partial class DashboardFinanciero_CuentaPorVencerResult
    {
        public int? Cco_Id { get; set; }
        public string? NombreAlumno { get; set; }
        public string? Cpa_Descripcion { get; set; }
        public DateTime? Cco_FechaVencimiento { get; set; }
        public decimal? Cco_MontoPendiente { get; set; }
        public int? DiasParaVencer { get; set; }
    }
}
