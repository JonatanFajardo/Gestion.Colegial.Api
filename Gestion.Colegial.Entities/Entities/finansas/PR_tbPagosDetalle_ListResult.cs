
#nullable enable
using System;
using System.ComponentModel.DataAnnotations;

namespace Gestion.Colegial.Entities.Entities;

public class PR_tbPagosDetalle_ListResult
{
    public int Pde_Id { get; set; }
    public int Pag_Id { get; set; }
    public int Cco_Id { get; set; }
    public decimal Pde_MontoAplicado { get; set; }
}
