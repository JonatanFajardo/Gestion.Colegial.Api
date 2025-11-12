
#nullable enable
using System;
using System.ComponentModel.DataAnnotations;

namespace Gestion.Colegial.Entities.Entities;

public class PR_tbRecibos_DetailResult
{
    public int Rec_Id { get; set; }
    public int Pag_Id { get; set; }
    public string Rec_NumeroRecibo { get; set; } = string.Empty;
    public DateTime Rec_FechaEmision { get; set; }
    public string? Rec_RutaArchivo { get; set; }
    public decimal MontoTotal { get; set; }
    public string FormaPago { get; set; } = string.Empty;
}
