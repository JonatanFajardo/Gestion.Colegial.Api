using System;

namespace Gestion.Colegial.Entities.DTOs.finansas
{
    public class ResumenFinancieroDto
    {
        public decimal totalDeuda { get; set; }
        public decimal totalPagado { get; set; }
        public decimal totalPendiente { get; set; }
        public decimal totalMora { get; set; }
    }
}
