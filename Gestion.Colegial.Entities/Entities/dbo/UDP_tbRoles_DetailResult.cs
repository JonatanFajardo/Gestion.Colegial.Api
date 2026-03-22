using System;

namespace Gestion.Colegial.Entities.Entities
{
    public class UDP_tbRoles_DetailResult
    {
        public int Rol_Id { get; set; }
        public string Rol_Descripcion { get; set; }
        public bool Rol_Estado { get; set; }
        public DateTime? Rol_FechaRegistra { get; set; }
        public DateTime? Rol_FechaModifica { get; set; }
        public int CantidadPantallas { get; set; }
    }
}
