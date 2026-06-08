namespace Gestion.Colegial.Entities.Entities
{
    public partial class PR_Finanza_AnalisisIngresosResult
    {
        public string ConceptoPago { get; set; }
        public decimal TotalCobrado { get; set; }
        public decimal TotalPendiente { get; set; }
        public decimal PorcentajeCobrado { get; set; }
    }
}
