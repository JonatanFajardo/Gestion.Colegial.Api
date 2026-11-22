namespace Gestion.Colegial.Entities.DTOs.finansas
{
    /// <summary>Anular un pago. Destino: "Devuelto" | "SaldoFavor".</summary>
    public class PagoAnularDto
    {
        public int PagoId { get; set; }
        public string? Motivo { get; set; }
        public string? Destino { get; set; }
        public int? UsuarioId { get; set; }
    }

    /// <summary>Perdonar parte o todo un cargo. Tipo: "Exoneración" | "Beca" | "Ajuste".</summary>
    public class CuentaCobrarPerdonarDto
    {
        public int CuentaCobrarId { get; set; }
        public decimal Monto { get; set; }
        public string? Tipo { get; set; }
        public string? Motivo { get; set; }
        public int? UsuarioId { get; set; }
    }

    /// <summary>Devolver saldo a favor. Metodo: "Efectivo" | "Transferencia" | "Cheque".</summary>
    public class SaldoFavorDevolverDto
    {
        public int AlumnoId { get; set; }
        public decimal Monto { get; set; }
        public string? Metodo { get; set; }
        public string? Motivo { get; set; }
        public int? UsuarioId { get; set; }
    }

    /// <summary>Aplicar saldo a favor a los cargos pendientes, del más viejo al más nuevo.</summary>
    public class SaldoFavorAplicarDto
    {
        public int AlumnoId { get; set; }
        public decimal Monto { get; set; }
        public string? Motivo { get; set; }
        public int? UsuarioId { get; set; }
    }
}
