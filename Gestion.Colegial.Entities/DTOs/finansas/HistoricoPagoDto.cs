using System;

namespace Gestion.Colegial.Entities.DTOs.finansas
{
    public class HistoricoPagoDto
    {
        public int pagoId { get; set; }
        public DateTime fechaPago { get; set; }
        public decimal montoTotal { get; set; }
        public string formaPago { get; set; }
        public string numeroReferencia { get; set; }
        public string numeroRecibo { get; set; }
        public string usuario { get; set; }
        public string observaciones { get; set; }
    }
}
