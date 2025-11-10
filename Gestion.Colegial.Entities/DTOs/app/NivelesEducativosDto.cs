#nullable disable

namespace Gestion.Colegial.Entities.DTOs
{
    public partial class tbNivelesEducativosDto
    {
        public int NivelId { get; set; }
        public string DescripcionNivel { get; set; }
        public bool EsActivo { get; set; }
        public bool EsEliminado { get; set; }
        public int UsuarioRegistra { get; set; }
        public DateTime FechaRegistra { get; set; }
        public int? UsuarioModifica { get; set; }
        public DateTime? FechaModifica { get; set; }
    }
}
