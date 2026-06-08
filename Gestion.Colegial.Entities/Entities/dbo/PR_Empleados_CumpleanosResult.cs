using System;

namespace Gestion.Colegial.Entities.Entities
{
    public class PR_Empleados_CumpleanosResult
    {
        public int Emp_Id { get; set; }
        public string Emp_Codigo { get; set; }
        public string NombreCompleto { get; set; }
        public DateTime? Per_FechaNacimiento { get; set; }
        public int DiaCumpleanos { get; set; }
        public int Edad { get; set; }
        public string Per_Telefono { get; set; }
        public string Per_CorreoElectronico { get; set; }
        public string Per_Imagen { get; set; }
        public string Per_Sexo { get; set; }
    }
}
