
#nullable enable
using System;
using System.ComponentModel.DataAnnotations;

namespace Gestion.Colegial.Entities.Entities;

public class PR_ReportesFinancieros_EstadoCuentaAlumnoResult
{
    public int Alu_Id { get; set; }
    public string AlumnoNombre { get; set; } = string.Empty;
    public string? AlumnoIdentidad { get; set; }

    // Resumen de cuentas
    public decimal TotalCargos { get; set; }
    public decimal TotalPagado { get; set; }
    public decimal TotalPendiente { get; set; }
    public decimal TotalDescuentos { get; set; }
    public decimal TotalMora { get; set; }

    // Detalle de cuenta específica (si aplica)
    public int? Cco_Id { get; set; }
    public string? Concepto { get; set; }
    public decimal? MontoOriginal { get; set; }
    public decimal? MontoPendiente { get; set; }
    public DateTime? FechaVencimiento { get; set; }
    public string? Estado { get; set; }
}
