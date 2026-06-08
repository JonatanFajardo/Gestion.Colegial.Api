namespace Gestion.Colegial.Entities.Entities
{
    public partial class KPIsAcademicosResult
    {
        public int Anio { get; set; }
        public int TotalAlumnosActivos { get; set; }
        public int TotalDocentes { get; set; }
        public decimal? PromedioGeneralInstitucional { get; set; }
        public decimal? PorcentajeAsistencia { get; set; }
    }
}
