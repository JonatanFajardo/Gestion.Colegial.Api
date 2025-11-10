#nullable disable

namespace Gestion.Colegial.Entities.DTOs
{
    public partial class tbMateriasDto
    {
        public int MateriaId { get; set; }
        public string NombreMateria { get; set; }
        public int DuracionId { get; set; }
        public int CursoId { get; set; }
        public bool EsActivo { get; set; }
        public bool EsEliminado { get; set; }
        public int UsuarioRegistra { get; set; }
        public DateTime FechaRegistra { get; set; }
        public int? UsuarioModifica { get; set; }
        public DateTime? FechaModifica { get; set; }
    }
}
