#nullable disable

namespace Gestion.Colegial.Entities.DTOs
{
    public partial class tbDuracionesDto
    {
        public int DuracionId { get; set; }
        public string DescripcionDuracion { get; set; }
        public bool EsEliminado { get; set; }
        public int UsuarioRegistra { get; set; }
        public DateTime FechaRegistra { get; set; }
        public int? UsuarioModifica { get; set; }
        public DateTime? FechaModifica { get; set; }
    }
}
