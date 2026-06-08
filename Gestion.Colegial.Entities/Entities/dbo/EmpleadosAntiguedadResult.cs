using System;

namespace Gestion.Colegial.Entities.Entities
{
    public partial class EmpleadosAntiguedadResult
    {
        public int Emp_Id { get; set; }
        public string Emp_Codigo { get; set; }
        public string NombreCompleto { get; set; }
        public DateTime FechaIngreso { get; set; }
        public int Anos { get; set; }
        public int Meses { get; set; }
        public string Per_Imagen { get; set; }
    }
}
