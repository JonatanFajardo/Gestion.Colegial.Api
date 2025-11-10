namespace Gestion.Colegial.Entities.DTOs.dbo
{
    public partial class HorarioAlumnoListDto    {
        public int HorarioAlumnoId { get; set; }
        public string NombreCurso { get; set; }
        public string DescripcionCursoNivel { get; set; }
        public string NombreMateria { get; set; }
        public string HoraInicio { get; set; }
        public string HoraFin { get; set; }
        public string DescripcionDia { get; set; }
    }
}
