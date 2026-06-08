using System;

namespace Gestion.Colegial.Entities.Entities
{
    public partial class DashboardFinanciero_CobrosPorDiaResult
    {
        public int? Dia { get; set; }
        public DateTime? Fecha { get; set; }
        public decimal? Total { get; set; }
        public int? Cantidad { get; set; }
    }
}
