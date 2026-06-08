using System;

namespace Gestion.Colegial.Entities.Entities
{
    public class DashboardRRHH_AsistenciaDiariaResult
    {
        public DateTime Fecha     { get; set; }
        public int      Presentes { get; set; }
        public int      Ausentes  { get; set; }
        public int      Tardanzas { get; set; }
        public int      Permisos  { get; set; }
    }
}
