using System;

namespace Gestion.Colegial.Entities.Entities
{
    public partial class DashboardRRHH_VacacionesPendientesResult
    {
        public int Vac_Id { get; set; }
        public string Vac_Tipo { get; set; }
        public DateTime Vac_FechaInicio { get; set; }
        public DateTime Vac_FechaFin { get; set; }
        public int Vac_DiasTotal { get; set; }
        public string Vac_Motivo { get; set; }
        public string NombreEmpleado { get; set; }
    }
}
