using System;

namespace Gestion.Colegial.Entities.Entities
{
    public partial class EstadoCuentaResult
    {
        public int Cco_Id { get; set; }
        public int Cco_Mes { get; set; }
        public int Cco_Anio { get; set; }
        public string Cpa_Descripcion { get; set; }
        public decimal Cco_MontoOriginal { get; set; }
        public decimal Cco_MontoDescuento { get; set; }
        public decimal Cco_MontoMora { get; set; }
        public decimal Cco_MontoTotal { get; set; }
        public decimal Cco_MontoPendiente { get; set; }
        public DateTime Cco_FechaEmision { get; set; }
        public DateTime Cco_FechaVencimiento { get; set; }
        public string Estado { get; set; }
        public decimal MontoPagado { get; set; }
    }
}
