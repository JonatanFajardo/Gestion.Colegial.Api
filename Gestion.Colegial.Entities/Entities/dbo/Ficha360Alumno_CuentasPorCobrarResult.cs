using System;

namespace Gestion.Colegial.Entities.Entities
{
    public partial class Ficha360Alumno_CuentasPorCobrarResult
    {
        public int Cco_Id { get; set; }
        public int Cco_Mes { get; set; }
        public int Cco_Anio { get; set; }
        public decimal Cco_MontoTotal { get; set; }
        public decimal Cco_MontoPendiente { get; set; }
        public DateTime Cco_FechaVencimiento { get; set; }
        public string Epa_Descripcion { get; set; }
        public string Cpa_Descripcion { get; set; }
    }
}
