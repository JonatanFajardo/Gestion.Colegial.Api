using System;

namespace Gestion.Colegial.Entities.Entities
{
    public partial class PR_tbArqueosCaja_LastResult
    {
        public int Arq_Id { get; set; }
        public DateTime Arq_Fecha { get; set; }
        public decimal Arq_TotalEfectivo { get; set; }
        public decimal Arq_TotalTransferencia { get; set; }
        public decimal Arq_TotalTarjeta { get; set; }
        public decimal Arq_TotalGeneral { get; set; }
        public string Arq_Observaciones { get; set; }
    }
}
