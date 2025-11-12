
#nullable enable
using System;
using System.ComponentModel.DataAnnotations;

namespace Gestion.Colegial.Entities.Entities;

public class PR_tbDescuentosAplicados_DetailResult
{
    public int Dap_Id { get; set; }
    public int Cco_Id { get; set; }
    public int Des_Id { get; set; }
    public string Descuento { get; set; } = string.Empty;
    public decimal Dap_MontoAplicado { get; set; }
    public string? Dap_Justificacion { get; set; }
    public DateTime Per_FechaRegistra { get; set; }
}
