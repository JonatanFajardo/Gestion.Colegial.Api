namespace Gestion.Colegial.Entities.Entities;

public class PR_tbPagos_GetReciboResult
{
    public int ReciboId { get; set; }
    public string NumeroRecibo { get; set; } = string.Empty;
    public DateTime FechaEmision { get; set; }
    public int PagoId { get; set; }
    public DateTime FechaPago { get; set; }
    public decimal MontoTotal { get; set; }
    public string? NumeroReferencia { get; set; }
    public string? Observaciones { get; set; }
    public string FormaPago { get; set; } = string.Empty;
    public string AlumnoNombre { get; set; } = string.Empty;
    public string? AlumnoIdentidad { get; set; }
    public string? EncargadoNombre { get; set; }
    public string NombreCompletoUsuarioRegistra { get; set; } = string.Empty;
    public bool EsAnulado { get; set; }
    public string? MotivoAnulacion { get; set; }
    public DateTime? FechaAnulacion { get; set; }
    public decimal SaldoPendiente { get; set; }
    public string? ColegioNombre { get; set; }
    public string? ColegioTelefono { get; set; }
    public string? ColegioDireccion { get; set; }
    public string? Lineas { get; set; }
}
