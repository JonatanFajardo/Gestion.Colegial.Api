namespace Gestion.Colegial.Entities.Entities
{
    public partial class PromedioAlumnoResult
    {
        public int Alu_Id { get; set; }
        public string Alu_NombreCompleto { get; set; }
        public decimal Promedio { get; set; }
        public bool EsBajo { get; set; }
    }
}
