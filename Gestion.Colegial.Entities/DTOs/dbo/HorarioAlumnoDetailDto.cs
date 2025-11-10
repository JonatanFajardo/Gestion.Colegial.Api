namespace Gestion.Colegial.Entities.DTOs.dbo
{
    public partial class HorarioAlumnoDetailDto    {
        public int HorarioAlumnoId { get; set; }
        public string NombreCurso { get; set; }
        public string DescripcionCursoNivel { get; set; }
        public string NombreMateria { get; set; }
        public string HoraInicio { get; set; }
        public string HoraFin { get; set; }
        public string DescripcionDia { get; set; }
        public string DescripcionSeccion { get; set; }
        public string DescripcionAula { get; set; }
        public string NombreEmpleado { get; set; }
        public string DescripcionSemestre { get; set; }
        public string DescripcionModalidad { get; set; }
        public int Anio { get; set; }
        public string NombreUsuarioRegistraHorarioAlumno { get; set; }
        public DateTime FechaRegistroHorarioAlumno { get; set; }
        public string NombreUsuarioModificaHorarioAlumno { get; set; }
        public DateTime? FechaModificacionHorarioAlumno { get; set; }
    }
}
