using System;

namespace Gestion.Colegial.Entities.DTOs.finansas
{
    public class CargoPendienteDto
    {
        public int cuentaCobrarId { get; set; }
        public string conceptoPago { get; set; }
        public decimal montoOriginal { get; set; }
        public decimal montoDescuento { get; set; }
        public decimal montoMora { get; set; }
        public decimal montoTotal { get; set; }
        public DateTime fechaVencimiento { get; set; }
        public string estadoPago { get; set; }
        public DateTime fechaCreacion { get; set; }
        public string observaciones { get; set; }
    }
}
