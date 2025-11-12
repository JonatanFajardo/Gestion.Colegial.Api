
#nullable enable
using System;
using System.ComponentModel.DataAnnotations;

namespace Gestion.Colegial.Entities.Entities;

public class PR_tbPagos_FindResult
{
    public int Pag_Id { get; set; }
    public int Alu_Id { get; set; }
    public int? Enc_Id { get; set; }
    public int Fpa_Id { get; set; }
    public decimal Pag_MontoTotal { get; set; }
    public DateTime Pag_FechaPago { get; set; }
    public string? Pag_NumeroReferencia { get; set; }
    public string? Pag_Observaciones { get; set; }
    public int Usu_Id { get; set; }
    public bool Per_EsEliminado { get; set; }
    public int Per_UsuarioRegistra { get; set; }
    public DateTime Per_FechaRegistra { get; set; }
    public int? Per_UsuarioModifica { get; set; }
    public DateTime? Per_FechaModifica { get; set; }
}
