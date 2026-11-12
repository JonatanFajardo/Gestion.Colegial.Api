namespace Gestion.Colegial.Entities.Entities
{
    public partial class MorosidadPorNivelResult
    {
        public string Cur_Nombre { get; set; }
        public int TotalAlumnos { get; set; }
        public int AlumnosMorosos { get; set; }
        public decimal MontoMoroso { get; set; }
        public decimal PorcentajeMorosidad { get; set; }
    }
}
