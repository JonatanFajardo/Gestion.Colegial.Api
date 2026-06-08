namespace Gestion.Colegial.Entities.Entities
{
    public partial class KPIsFinancierosResult
    {
        public int Anio { get; set; }
        public int? Mes { get; set; }
        public decimal TotalCobrado { get; set; }
        public decimal TotalPendiente { get; set; }
        public int TotalMorosos { get; set; }
        public decimal? PorcentajeRecuperacion { get; set; }
    }
}
