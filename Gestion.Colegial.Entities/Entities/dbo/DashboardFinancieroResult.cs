using System.Collections.Generic;

namespace Gestion.Colegial.Entities.Entities
{
    public class DashboardFinancieroResult
    {
        public DashboardFinanciero_KpisFinancierosResult? KpisFinancieros { get; set; }
        public List<DashboardFinanciero_IngresosMensualesResult>? IngresosMensuales { get; set; }
        public List<DashboardFinanciero_CobrosPorFormaPagoResult>? CobrosPorFormaPago { get; set; }
        public List<DashboardFinanciero_MorosidadPorConceptoResult>? MorosidadPorConcepto { get; set; }
        public List<DashboardFinanciero_TopAlumnoMorosoResult>? TopAlumnosMorosos { get; set; }
        public List<DashboardFinanciero_CobrosPorDiaResult>? CobrosPorDia { get; set; }
        public List<DashboardFinanciero_EstadoCarteraResult>? EstadoCartera { get; set; }
        public List<DashboardFinanciero_CuentaPorVencerResult>? CuentasPorVencer { get; set; }
        public List<DashboardFinanciero_CobrosPorConceptoResult>? CobrosPorConcepto { get; set; }
        public List<DashboardFinanciero_AlertaResult>? Alertas { get; set; }
    }
}
