#nullable disable

namespace Gestion.Colegial.Entities.DTOs
{
    public partial class tbEstadosDto
    {
        public int EstadoId { get; set; }
        public string DescripcionEstado { get; set; }
        public bool EsEliminado { get; set; }
        public int UsuarioRegistra { get; set; }
        public DateTime FechaRegistra { get; set; }
        public int? UsuarioModifica { get; set; }
        public DateTime? FechaModifica { get; set; }
    }
}
