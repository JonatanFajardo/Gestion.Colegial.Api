#nullable disable

namespace Gestion.Colegial.Entities.DTOs
{
    public partial class tbDiasDto
    {
        public int DiaId { get; set; }
        public string DescripcionDia { get; set; }
        public bool EsEliminado { get; set; }
        public int UsuarioRegistra { get; set; }
        public DateTime FechaRegistra { get; set; }
        public int? UsuarioModifica { get; set; }
        public DateTime? FechaModifica { get; set; }
    }
}
