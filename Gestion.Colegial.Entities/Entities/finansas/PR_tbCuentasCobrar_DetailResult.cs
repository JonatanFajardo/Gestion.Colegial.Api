
#nullable enable
using System;
using System.ComponentModel.DataAnnotations;

namespace Gestion.Colegial.Entities.Entities;

public class PR_tbCuentasCobrar_DetailResult
{
    public int Cco_Id { get; set; }
    public string Concepto { get; set; } = string.Empty;
    public string Estado { get; set; } = string.Empty;
    public decimal Cco_MontoTotal { get; set; }
    public decimal Cco_MontoPendiente { get; set; }
    public decimal TotalPagado { get; set; }
}
