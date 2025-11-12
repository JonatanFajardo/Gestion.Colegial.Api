
#nullable enable
using System;
using System.ComponentModel.DataAnnotations;

namespace Gestion.Colegial.Entities.Entities;

public class PR_tbRecibos_ListResult
{
    public int Rec_Id { get; set; }
    public int Pag_Id { get; set; }
    public string Rec_NumeroRecibo { get; set; } = string.Empty;
    public DateTime Rec_FechaEmision { get; set; }
}
