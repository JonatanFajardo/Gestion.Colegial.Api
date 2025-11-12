
#nullable enable
using System;
using System.ComponentModel.DataAnnotations;

namespace Gestion.Colegial.Entities.Entities;

public class PR_tbCuentasCobrar_FindResult
{
    public int Cco_Id { get; set; }
    public int Alu_Id { get; set; }
    public int Cpa_Id { get; set; }
    public int? Tar_Id { get; set; }
    public decimal Cco_MontoOriginal { get; set; }
    public decimal Cco_MontoDescuento { get; set; }
    public decimal Cco_MontoMora { get; set; }
    public decimal Cco_MontoTotal { get; set; }
    public decimal Cco_MontoPendiente { get; set; }
    public DateTime Cco_FechaEmision { get; set; }
    public DateTime Cco_FechaVencimiento { get; set; }
    public int Epa_Id { get; set; }
    public string? Cco_Observaciones { get; set; }
    public bool Per_EsEliminado { get; set; }
    public int Per_UsuarioRegistra { get; set; }
    public DateTime Per_FechaRegistra { get; set; }
    public int? Per_UsuarioModifica { get; set; }
    public DateTime? Per_FechaModifica { get; set; }
}
