using System;

namespace Gestion.Colegial.Entities.Entities
{
    public partial class DashboardCajero_UltimoArqueoResult
    {
        public int? Arq_Id { get; set; }
        public DateTime? Arq_Fecha { get; set; }
        public decimal? Arq_TotalGeneral { get; set; }
        public string? Arq_Observaciones { get; set; }
    }
}
