using System;

namespace Gestion.Colegial.Entities.Entities
{
    public partial class Ficha360Alumno_DatosPersonalesResult
    {
        public int Alu_Id { get; set; }
        public int AnioCursado { get; set; }
        public decimal? PromedioAnual { get; set; }
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
        public string Cur_Nombre { get; set; }
        public string Cun_Descripcion { get; set; }
        public string Sec_Descripcion { get; set; }
    }
}
