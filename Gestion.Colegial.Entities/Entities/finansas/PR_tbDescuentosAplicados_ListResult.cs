
#nullable enable
using System;
using System.ComponentModel.DataAnnotations;

namespace Gestion.Colegial.Entities.Entities;

public class PR_tbDescuentosAplicados_ListResult
{
    public int Dap_Id { get; set; }
    public int Cco_Id { get; set; }
    public int Des_Id { get; set; }
    public decimal Dap_MontoAplicado { get; set; }
}
