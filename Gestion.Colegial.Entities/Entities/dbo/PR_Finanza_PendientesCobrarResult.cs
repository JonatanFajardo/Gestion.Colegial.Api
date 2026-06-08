using System;

namespace Gestion.Colegial.Entities.Entities
{
    public class PR_Finanza_PendientesCobrarResult
    {
        public int Cco_Id { get; set; }
        public int Cco_Mes { get; set; }
        public int Cco_Anio { get; set; }
        public decimal Cco_MontoOriginal { get; set; }
        public decimal Cco_MontoDescuento { get; set; }
        public decimal Cco_MontoMora { get; set; }
        public decimal Cco_MontoTotal { get; set; }
        public decimal Cco_MontoPendiente { get; set; }
        public DateTime Cco_FechaEmision { get; set; }
        public DateTime Cco_FechaVencimiento { get; set; }
        public int DiasVencida { get; set; }
        public bool EsVencida { get; set; }
        public string Cco_Observaciones { get; set; }
        public int Cpa_Id { get; set; }
        public string Cpa_Descripcion { get; set; }
        public int Epa_Id { get; set; }
        public string Epa_Descripcion { get; set; }
        public int Alu_Id { get; set; }
        public string Alu_NombreCompleto { get; set; }
        public string Alu_Identidad { get; set; }
        public string Alu_Telefono { get; set; }
        public string Cur_Nombre { get; set; }
        public string Sec_Descripcion { get; set; }
    }
}
