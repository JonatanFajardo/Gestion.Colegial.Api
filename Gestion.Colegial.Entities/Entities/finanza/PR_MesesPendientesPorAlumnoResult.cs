using System;

namespace Gestion.Colegial.Entities.Entities
{
    public class PR_MesesPendientesPorAlumnoResult
    {
        public byte Mes { get; set; }
        public string NombreMes { get; set; }
        public short Anio { get; set; }
        public string Estado { get; set; }
        public decimal MontoTotal { get; set; }
        public decimal MontoPendiente { get; set; }
        public decimal MontoPagado { get; set; }
        public DateTime? Cco_FechaVencimiento { get; set; }
        public string EstadoVencimiento { get; set; }
        public int DiasVencido { get; set; }
    }
}
