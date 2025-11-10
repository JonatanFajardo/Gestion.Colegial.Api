#nullable disable

namespace Gestion.Colegial.Entities.DTOs
{
    public partial class tbSemestresDto
    {
        public int SemestreId { get; set; }
        public string DescripcionSemestre { get; set; }
        public bool EsActivo { get; set; }
        public bool EsEliminado { get; set; }
        public int UsuarioRegistra { get; set; }
        public DateTime FechaRegistra { get; set; }
        public int? UsuarioModifica { get; set; }
        public DateTime? FechaModifica { get; set; }
    }
}
