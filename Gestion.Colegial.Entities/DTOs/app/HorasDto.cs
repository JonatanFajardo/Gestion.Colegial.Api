#nullable disable

namespace Gestion.Colegial.Entities.DTOs
{
    public partial class tbHorasDto
    {
        public int HorarioId { get; set; }
        public string Hora { get; set; }
        public bool EsEliminado { get; set; }
        public int UsuarioRegistra { get; set; }
        public DateTime FechaRegistra { get; set; }
        public int? UsuarioModifica { get; set; }
        public DateTime? FechaModifica { get; set; }
    }
}
