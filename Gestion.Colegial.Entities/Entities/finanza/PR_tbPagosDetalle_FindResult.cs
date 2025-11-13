
#nullable enable
using System;
using System.ComponentModel.DataAnnotations;

namespace Gestion.Colegial.Entities.Entities;

public class PR_tbPagosDetalle_FindResult
{
    public int Pde_Id { get; set; }
    public int Pag_Id { get; set; }
    public int Cco_Id { get; set; }
    public decimal Pde_MontoAplicado { get; set; }
    public bool Per_EsEliminado { get; set; }
    public int Per_UsuarioRegistra { get; set; }
    public DateTime Per_FechaRegistra { get; set; }
    public int? Per_UsuarioModifica { get; set; }
    public DateTime? Per_FechaModifica { get; set; }
}
