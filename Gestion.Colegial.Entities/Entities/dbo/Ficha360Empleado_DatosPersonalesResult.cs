using System;

namespace Gestion.Colegial.Entities.Entities
{
    public partial class Ficha360Empleado_DatosPersonalesResult
    {
        public int Emp_Id { get; set; }
        public string Emp_Codigo { get; set; }
        public string Per_PrimerNombre { get; set; }
        public string Per_SegundoNombre { get; set; }
        public string Per_ApellidoPaterno { get; set; }
        public string Per_ApellidoMaterno { get; set; }
        public string Per_Identidad { get; set; }
        public DateTime? Per_FechaNacimiento { get; set; }
        public string Per_Sexo { get; set; }
        public string Per_Telefono { get; set; }
        public string Per_CorreoElectronico { get; set; }
        public string Per_Direccion { get; set; }
        public string Per_Imagen { get; set; }
        public DateTime? FechaContratacion { get; set; }
    }
}
