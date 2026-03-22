using System.Collections.Generic;

namespace Gestion.Colegial.Entities.DTOs
{
    public class RolConPantallasDTO
    {
        public int Rol_Id { get; set; }
        public string Rol_Descripcion { get; set; }
        public bool Rol_Estado { get; set; }
        public List<int> PantallaIds { get; set; }
    }
}
