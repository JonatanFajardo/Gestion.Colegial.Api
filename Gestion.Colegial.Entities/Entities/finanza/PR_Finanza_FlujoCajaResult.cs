namespace Gestion.Colegial.Entities.Entities
{
    public partial class PR_Finanza_FlujoCajaResult
    {
        public int Mes { get; set; }
        public string NombreMes { get; set; }
        public decimal TotalIngresos { get; set; }
        public decimal TotalPendiente { get; set; }
        public decimal SaldoNeto { get; set; }
    }
}
