namespace Gestion.Colegial.Entities.DTOs.dbo
{
    public partial class HorarioAlumnoFindDto    {
        public int HorarioAlumnoId { get; set; }
        public int CursoId { get; set; }
        public string NombreCurso { get; set; }
        public int CursoNivelId { get; set; }
        public string DescripcionCursoNivel { get; set; }
        public int MateriaId { get; set; }
        public string NombreMateria { get; set; }
        public int HoraInicioId { get; set; }
        public string HoraInicio { get; set; }
        public int HoraFinId { get; set; }
        public string HoraFin { get; set; }
        public int DiaId { get; set; }
        public string DescripcionDia { get; set; }
        public int SeccionId { get; set; }
        public string DescripcionSeccion { get; set; }
        public int AulaId { get; set; }
        public string DescripcionAula { get; set; }
        public int EmpleadoId { get; set; }
        public string NombreEmpleado { get; set; }
        public int SemestreId { get; set; }
        public string DescripcionSemestre { get; set; }
        public int? ModalidadId { get; set; }
        public string DescripcionModalidad { get; set; }
        public int Anio { get; set; }
    }
}
