
#nullable enable
using System;
using System.ComponentModel.DataAnnotations;

namespace Gestion.Colegial.Entities.Entities;

public class PR_tbCuentasCobrar_ListDeudoresResult
{
    public string NombreCompleto { get; set; } = string.Empty;
    public string Identidad { get; set; } = string.Empty;
    public string Nivel { get; set; } = string.Empty;
    public string Curso { get; set; } = string.Empty;
    public decimal TotalDeuda { get; set; }
    public decimal MontoPendiente { get; set; }
    public DateTime UltimaFechaVencimiento { get; set; }
    public string EstadoPago { get; set; } = string.Empty;
}
