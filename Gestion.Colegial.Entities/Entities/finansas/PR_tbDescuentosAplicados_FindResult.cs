
#nullable enable
using System;
using System.ComponentModel.DataAnnotations;

namespace Gestion.Colegial.Entities.Entities;

public class PR_tbDescuentosAplicados_FindResult
{
    public int Dap_Id { get; set; }
    public int Cco_Id { get; set; }
    public int Des_Id { get; set; }
    public decimal Dap_MontoAplicado { get; set; }
    public string? Dap_Justificacion { get; set; }
    public bool Per_EsEliminado { get; set; }
    public int Per_UsuarioRegistra { get; set; }
    public DateTime Per_FechaRegistra { get; set; }
    public int? Per_UsuarioModifica { get; set; }
    public DateTime? Per_FechaModifica { get; set; }
}
