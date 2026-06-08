using System;

namespace Gestion.Colegial.Entities.Entities
{
    public class DashboardRRHH_SolicitudDetalleResult
    {
        public int      Vac_Id         { get; set; }
        public string?  Tipo           { get; set; }
        public DateTime Vac_FechaInicio { get; set; }
        public DateTime Vac_FechaFin   { get; set; }
        public int      Vac_DiasTotal  { get; set; }
        public string?  Vac_Motivo     { get; set; }
        public string?  NombreEmpleado { get; set; }
        public string?  Cargo          { get; set; }
        public string?  Departamento   { get; set; }
    }
}
