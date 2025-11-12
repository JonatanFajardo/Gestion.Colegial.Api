
#nullable enable
using System;
using System.ComponentModel.DataAnnotations;

namespace Gestion.Colegial.Entities.Entities;

public class PR_tbPagos_ListResult
{
    public int Pag_Id { get; set; }
    public int Alu_Id { get; set; }
    public string FormaPago { get; set; } = string.Empty;
    public decimal Pag_MontoTotal { get; set; }
    public DateTime Pag_FechaPago { get; set; }
}
