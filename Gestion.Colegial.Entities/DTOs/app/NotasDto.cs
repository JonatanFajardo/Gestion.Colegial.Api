#nullable disable

namespace Gestion.Colegial.Entities.DTOs
{
    public partial class tbNotasDto
    {
        public int NotaId { get; set; }
        public int? AlumnoId { get; set; }
        public int? AulaId { get; set; }
        public int? SeccionId { get; set; }
        public int ValorNota { get; set; }
        public int MateriaId { get; set; }
        public int SemestreId { get; set; }
        public int ParcialId { get; set; }
        public DateTime AnioNota { get; set; }
        public bool EsActivo { get; set; }
        public bool EsEliminado { get; set; }
        public int UsuarioRegistra { get; set; }
        public DateTime FechaRegistra { get; set; }
        public int? UsuarioModifica { get; set; }
        public DateTime? FechaModifica { get; set; }
    }
}
