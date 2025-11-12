
#nullable enable
using System;
using System.ComponentModel.DataAnnotations;

namespace Gestion.Colegial.Entities.Entities;

public class PR_tbRecibos_FindResult
{
    public int Rec_Id { get; set; }
    public int Pag_Id { get; set; }
    public string Rec_NumeroRecibo { get; set; } = string.Empty;
    public DateTime Rec_FechaEmision { get; set; }
    public string? Rec_RutaArchivo { get; set; }
    public bool Per_EsEliminado { get; set; }
    public int Per_UsuarioRegistra { get; set; }
    public DateTime Per_FechaRegistra { get; set; }
    public int? Per_UsuarioModifica { get; set; }
    public DateTime? Per_FechaModifica { get; set; }
}
