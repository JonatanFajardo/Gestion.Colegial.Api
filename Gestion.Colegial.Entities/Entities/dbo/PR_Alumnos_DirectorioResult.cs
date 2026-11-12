using System;

namespace Gestion.Colegial.Entities.Entities
{
    public class PR_Alumnos_DirectorioResult
    {
        public int Alu_Id { get; set; }
        public int? AnioCursado { get; set; }
        public string Alu_NombreCompleto { get; set; }
        public string Alu_Identidad { get; set; }
        public DateTime? Alu_FechaNacimiento { get; set; }
        public string Alu_Sexo { get; set; }
        public string Alu_Imagen { get; set; }
        public string Alu_Telefono { get; set; }
        public string Alu_Correo { get; set; }
        public string Alu_Direccion { get; set; }
        public int? Cur_Id { get; set; }
        public string Cur_Nombre { get; set; }
        public int? Sec_Id { get; set; }
        public string Sec_Descripcion { get; set; }
        public string Cun_Descripcion { get; set; }
        public string Niv_Descripcion { get; set; }
        public int? Enc_Id { get; set; }
        public string Enc_Ocupacion { get; set; }
        public string Enc_NombreCompleto { get; set; }
        public string Enc_Telefono { get; set; }
        public string Enc_Correo { get; set; }
        public int? Par_Id { get; set; }
        public string Parentesco { get; set; }
    }
}
