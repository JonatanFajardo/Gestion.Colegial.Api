namespace Gestion.Colegial.Entities.DTOs
{
    public partial class DiferenciaEntreCantidadAlumnosAnioPasadoDashboardDto
    {
        public string NombreCurso { get; set; }
        public int? CantidadAlumnos { get; set; }
        public int? CantidadAnterior { get; set; }
        public int PorcentajeDiferencia { get; set; }
    }
}