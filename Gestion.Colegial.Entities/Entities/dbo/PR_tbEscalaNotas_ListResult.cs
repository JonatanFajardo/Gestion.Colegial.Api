namespace Gestion.Colegial.Entities.Entities
{
    public partial class PR_tbEscalaNotas_ListResult
    {
        public int Esc_Id { get; set; }
        public string Esc_Concepto { get; set; }
        public string Esc_Abreviatura { get; set; }
        public decimal Esc_NotaDesde { get; set; }
        public decimal Esc_NotaHasta { get; set; }
        public bool Esc_Aprueba { get; set; }
        public int Esc_Orden { get; set; }
    }
}
