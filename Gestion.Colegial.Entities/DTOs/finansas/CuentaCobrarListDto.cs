using System;

namespace Gestion.Colegial.Entities.DTOs.finansas
{
    public class CuentaCobrarListDto
    {
        public long? Fila { get; set; }
        public int CuentaCobrarId { get; set; }
        public string Concepto { get; set; }
        public string Alumno { get; set; }
        public decimal Pendiente { get; set; }
        public DateTime FechaVence { get; set; }
        public string EstadoPago { get; set; }
    }
}