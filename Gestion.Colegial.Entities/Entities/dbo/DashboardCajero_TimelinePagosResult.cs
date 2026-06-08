using System;

namespace Gestion.Colegial.Entities.Entities
{
    public partial class DashboardCajero_TimelinePagosResult
    {
        public int? Pag_Id { get; set; }
        public DateTime? Pag_FechaPago { get; set; }
        public decimal? Pag_MontoTotal { get; set; }
        public string? Pag_NumeroReferencia { get; set; }
        public string? Fpa_Descripcion { get; set; }
        public string? NombreAlumno { get; set; }
    }
}
