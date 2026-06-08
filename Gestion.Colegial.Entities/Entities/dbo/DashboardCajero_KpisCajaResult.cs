namespace Gestion.Colegial.Entities.Entities
{
    public partial class DashboardCajero_KpisCajaResult
    {
        public decimal? TotalCobradoHoy { get; set; }
        public int? CantidadCobros { get; set; }
        public decimal? TicketPromedio { get; set; }
        public decimal? MayorPago { get; set; }
        public int? AlumnosAtendidos { get; set; }
        public int? CuentasPendientesHoy { get; set; }
        public decimal? MontoPendienteHoy { get; set; }
        public decimal? MontoMoraHoy { get; set; }
    }
}
