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
        public int AlumnoId { get; set; }
        public string Identidad { get; set; }
        public string Nivel { get; set; }
        public string Grado { get; set; }
        public string Seccion { get; set; }
        public decimal MontoOriginal { get; set; }
        public decimal MontoDescuento { get; set; }
        public decimal MontoMora { get; set; }
        public decimal MontoTotal { get; set; }
        public int? Mes { get; set; }
        public int? Anio { get; set; }
    }
}