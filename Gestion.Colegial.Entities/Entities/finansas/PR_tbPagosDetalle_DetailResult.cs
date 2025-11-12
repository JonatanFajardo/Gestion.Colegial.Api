
#nullable enable
using System;
using System.ComponentModel.DataAnnotations;

namespace Gestion.Colegial.Entities.Entities;

public class PR_tbPagosDetalle_DetailResult
{
    public int Pde_Id { get; set; }
    public int Pag_Id { get; set; }
    public int Cco_Id { get; set; }
    public string Concepto { get; set; } = string.Empty;
    public decimal Pde_MontoAplicado { get; set; }
    public DateTime Per_FechaRegistra { get; set; }
}
