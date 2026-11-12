using System;

namespace Gestion.Colegial.Entities.Entities
{
    public class PR_Empleados_Asistencia_ListResult
    {
        public int AsiEmp_Id { get; set; }
        public int Emp_Id { get; set; }
        public string Emp_Codigo { get; set; }
        public string NombreEmpleado { get; set; }
        public string Per_Imagen { get; set; }
        public DateTime AsiEmp_Fecha { get; set; }
        public string AsiEmp_Tipo { get; set; }
        public string AsiEmp_Observacion { get; set; }
        public DateTime AsiEmp_FechaRegistra { get; set; }
    }
}
