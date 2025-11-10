#nullable disable

namespace Gestion.Colegial.Entities.DTOs
{
    public partial class tbParcialesDto
    {
        public int ParcialId { get; set; }
        public string DescripcionParcial { get; set; }
        public bool EsEliminado { get; set; }
        public int UsuarioRegistra { get; set; }
        public DateTime FechaRegistra { get; set; }
        public int? UsuarioModifica { get; set; }
        public DateTime? FechaModifica { get; set; }
    }
}
