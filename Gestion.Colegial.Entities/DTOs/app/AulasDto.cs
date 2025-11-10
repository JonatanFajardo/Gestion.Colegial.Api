#nullable disable

namespace Gestion.Colegial.Entities.DTOs
{
    public partial class tbAulasDto
    {
        public int AulaId { get; set; }
        public string DescripcionAula { get; set; }
        public bool EsEliminado { get; set; }
        public int UsuarioRegistra { get; set; }
        public DateTime FechaRegistra { get; set; }
        public int? UsuarioModifica { get; set; }
        public DateTime? FechaModifica { get; set; }
    }
}
