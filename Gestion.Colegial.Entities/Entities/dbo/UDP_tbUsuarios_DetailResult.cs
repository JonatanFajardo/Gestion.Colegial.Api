using System;

namespace Gestion.Colegial.Entities.Entities
{
    public class UDP_tbUsuarios_DetailResult
    {
        public int Usu_Id { get; set; }
        public string Usu_Name { get; set; }
        public string Rol_Descripcion { get; set; }
        public bool Usu_EsActivo { get; set; }
        public DateTime? Usu_FechaCreacion { get; set; }
        public DateTime? Usu_fechaModificacion { get; set; }
    }
}
