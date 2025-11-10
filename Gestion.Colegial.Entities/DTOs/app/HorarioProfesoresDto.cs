#nullable disable

namespace Gestion.Colegial.Entities.DTOs
{
    public partial class tbHorarioProfesoresDto
    {
        public int HorarioProfesorId { get; set; }
        public int CursoId { get; set; }
        public int CursoNivelId { get; set; }
        public int MateriaId { get; set; }
        public int EmpleadoId { get; set; }
        public int SeccionId { get; set; }
        public int AulaId { get; set; }
        public int HoraInicio { get; set; }
        public int HoraFinaliza { get; set; }
        public int DiaId { get; set; }
        public int SemestreId { get; set; }
        public int? ModalidadId { get; set; }
        public int Anio { get; set; }
        public bool EsEliminado { get; set; }
        public int UsuarioRegistra { get; set; }
        public DateTime FechaRegistra { get; set; }
        public int? UsuarioModifica { get; set; }
        public DateTime? FechaModifica { get; set; }
    }
}
