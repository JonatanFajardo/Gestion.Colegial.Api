namespace Gestion.Colegial.Entities.DTOs.finansas
{
    public class ReciboLineaDto
    {
        public string Concepto { get; set; } = string.Empty;
        public int? Mes { get; set; }
        public int? Anio { get; set; }
        public decimal Monto { get; set; }
        public decimal Descuento { get; set; }
    }

    public class ReciboPagoDto
    {
        public int ReciboId { get; set; }
        public string NumeroRecibo { get; set; } = string.Empty;
        public DateTime FechaEmision { get; set; }
        public int PagoId { get; set; }
        public DateTime FechaPago { get; set; }
        public decimal MontoTotal { get; set; }
        public string NumeroReferencia { get; set; } = string.Empty;
        public string Observaciones { get; set; } = string.Empty;
        public string FormaPago { get; set; } = string.Empty;
        public string AlumnoNombre { get; set; } = string.Empty;
        public string AlumnoIdentidad { get; set; } = string.Empty;
        public string EncargadoNombre { get; set; } = string.Empty;
        public string NombreCompletoUsuarioRegistra { get; set; } = string.Empty;
        public bool EsAnulado { get; set; }
        public string MotivoAnulacion { get; set; } = string.Empty;
        public DateTime? FechaAnulacion { get; set; }
        public decimal SaldoPendiente { get; set; }
        public string ColegioNombre { get; set; } = string.Empty;
        public string ColegioTelefono { get; set; } = string.Empty;
        public string ColegioDireccion { get; set; } = string.Empty;
        public List<ReciboLineaDto> Lineas { get; set; } = new();
    }
}
