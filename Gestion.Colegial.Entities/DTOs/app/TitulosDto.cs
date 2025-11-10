#nullable disable

namespace Gestion.Colegial.Entities.DTOs
{
    public partial class tbTitulosDto
    {
        public int TituloId { get; set; }
        public string DescripcionTitulo { get; set; }
        public bool EsEliminado { get; set; }
        public int UsuarioRegistra { get; set; }
        public DateTime FechaRegistra { get; set; }
        public int? UsuarioModifica { get; set; }
        public DateTime? FechaModifica { get; set; }
    }
}
