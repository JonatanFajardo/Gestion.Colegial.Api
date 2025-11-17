using System;

namespace Gestion.Colegial.Entities.DTOs.finansas
{
    public class PagoListDto
    {
        public long Fila { get; set; }
        public int PagoId { get; set; }
        public DateTime FechaPago { get; set; }
        public decimal MontoTotal { get; set; }
        public string NumeroReferencia { get; set; }
        public string Observaciones { get; set; }
        public string FormaPago { get; set; }
        public string Alumno { get; set; }
        public string Encargado { get; set; }
        public string Usuario { get; set; }
        public string NumeroRecibo { get; set; }
        public DateTime? FechaEmisionRecibo { get; set; }
    }
}
