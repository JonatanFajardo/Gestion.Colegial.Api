using System;

namespace Gestion.Colegial.Entities.Entities
{
    public partial class UDP_tbUsuarios_PerfilResult
    {
        public int Usu_Id { get; set; }
        public string Usu_Name { get; set; }
        public bool Usu_EsActivo { get; set; }
        public int Rol_Id { get; set; }
        public string Rol_Descripcion { get; set; }
        public int? Per_Id { get; set; }
        public string NombreCompleto { get; set; }
        public string Per_Imagen { get; set; }
        public string Per_Identidad { get; set; }
        public string Per_Telefono { get; set; }
        public string Per_Direccion { get; set; }
    }
}
