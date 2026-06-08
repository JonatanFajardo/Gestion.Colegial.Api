namespace Gestion.Colegial.Entities.Entities
{
    public partial class ComparativoAniosResult
    {
        public string Cur_Descripcion { get; set; }
        public int TotalAnioBase { get; set; }
        public int TotalAnioComparacion { get; set; }
        public int Diferencia { get; set; }
        public decimal? PorcentajeCambio { get; set; }
    }
}
