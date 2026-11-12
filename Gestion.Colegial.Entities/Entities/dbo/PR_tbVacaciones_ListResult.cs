using System;

namespace Gestion.Colegial.Entities.Entities
{
    public partial class PR_tbVacaciones_ListResult
    {
        public int Vac_Id { get; set; }
        public string Vac_Tipo { get; set; }
        public DateTime Vac_FechaInicio { get; set; }
        public DateTime Vac_FechaFin { get; set; }
        public int Vac_DiasTotal { get; set; }
        public string Vac_Estado { get; set; }
        public string Vac_Motivo { get; set; }
        public DateTime Vac_FechaRegistra { get; set; }
        public string NombreEmpleado { get; set; }
        public string Emp_Codigo { get; set; }
    }
}
