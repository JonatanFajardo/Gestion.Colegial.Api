using System;

namespace Gestion.Colegial.Entities.Entities
{
    public partial class tbPantallas
    {
        public int Pan_Id { get; set; }
        public string Pan_Descripcion { get; set; }
        public bool Pan_Estado { get; set; }
        public bool Pan_EsEliminado { get; set; }
        public int? Pan_UsuarioRegistra { get; set; }
        public DateTime Pan_FechaRegistra { get; set; }
        public int? Pan_UsuarioModifica { get; set; }
        public DateTime? Pan_FechaModifica { get; set; }
    }
}
