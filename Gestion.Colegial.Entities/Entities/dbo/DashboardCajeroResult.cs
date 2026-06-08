using System.Collections.Generic;

namespace Gestion.Colegial.Entities.Entities
{
    public class DashboardCajeroResult
    {
        public DashboardCajero_KpisCajaResult? Kpis { get; set; }
        public List<DashboardCajero_PagosPorHoraResult>? PagosPorHora { get; set; }
        public List<DashboardCajero_CobrosPorFormaPagoResult>? CobrosPorFormaPago { get; set; }
        public List<DashboardCajero_CobrosPorConceptoResult>? CobrosPorConcepto { get; set; }
        public List<DashboardCajero_TimelinePagosResult>? TimelinePagos { get; set; }
        public List<DashboardCajero_TopAlumnoDelDiaResult>? TopAlumnosDelDia { get; set; }
        public List<DashboardCajero_CuentaVencidaResult>? CuentasVencidas { get; set; }
        public DashboardCajero_UltimoArqueoResult? UltimoArqueo { get; set; }
        public List<DashboardCajero_ResumenSemanalResult>? ResumenSemanal { get; set; }
        public List<DashboardCajero_AlertaResult>? Alertas { get; set; }
    }
}
