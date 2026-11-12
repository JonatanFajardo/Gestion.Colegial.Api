namespace Gestion.Colegial.Entities.Entities
{
    public partial class DashboardFinanciero_KpisFinancierosResult
    {
        public decimal? TotalFacturadoMes { get; set; }
        public decimal? TotalCobradoMes { get; set; }
        public decimal? TotalPendiente { get; set; }
        public decimal? TotalMora { get; set; }
        public decimal? PorcentajeCobranza { get; set; }
        public int? CantidadPagosMes { get; set; }
        public decimal? TicketPromedioMes { get; set; }
        public int? AlumnosConPagos { get; set; }
        public int? AlumnosMorosos { get; set; }
        public int? CuentasActivas { get; set; }
    }
}
