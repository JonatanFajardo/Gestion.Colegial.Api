using System;

namespace Gestion.Colegial.Entities.Entities
{
    public partial class DashboardCajero_ResumenSemanalResult
    {
        public DateTime? Fecha { get; set; }
        public decimal? MontoTotal { get; set; }
        public int? CantidadCobros { get; set; }
    }
}
