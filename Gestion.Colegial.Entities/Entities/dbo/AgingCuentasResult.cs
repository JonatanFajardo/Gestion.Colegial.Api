namespace Gestion.Colegial.Entities.Entities
{
    public partial class AgingCuentasResult
    {
        public string NombreAlumno { get; set; }
        public int Alu_Id { get; set; }
        public decimal Rango_1_30 { get; set; }
        public decimal Rango_31_60 { get; set; }
        public decimal Rango_61_90 { get; set; }
        public decimal Rango_Mas90 { get; set; }
        public decimal TotalDeuda { get; set; }
    }
}
