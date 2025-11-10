#nullable disable

namespace Gestion.Colegial.Entities.DTOs
{
    public partial class tbAlumnosDto
    {
        public int AlumnoId { get; set; }
        public int PersonaId { get; set; }
        public int? NivelId { get; set; }
        public int? CursoNivelId { get; set; }
        public int? ModalidadId { get; set; }
        public int CursoId { get; set; }
        public int? SeccionId { get; set; }
        public int EstadoId { get; set; }
        public int? AnioCursado { get; set; }
        public decimal? PromedioAnual { get; set; }
    }
}
