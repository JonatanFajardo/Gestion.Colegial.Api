using System;

namespace Gestion.Colegial.Entities.Entities
{
    public partial class Ficha360Empleado_HistorialVacacionesResult
    {
        public string Vac_Tipo { get; set; }
        public DateTime Vac_FechaInicio { get; set; }
        public DateTime Vac_FechaFin { get; set; }
        public int Vac_DiasTotal { get; set; }
        public string Vac_Estado { get; set; }
        public string Vac_Motivo { get; set; }
    }
}
