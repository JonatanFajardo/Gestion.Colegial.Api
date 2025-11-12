
#nullable enable
using System;
using System.ComponentModel.DataAnnotations;

namespace Gestion.Colegial.Entities.Entities;

public class PR_tbTarifas_FindResult
{
    public int Tar_Id { get; set; }
    public int Cpa_Id { get; set; }
    public int? Niv_Id { get; set; }
    public int? Cun_Id { get; set; }
    public decimal Tar_Monto { get; set; }
    public short Tar_AnioVigencia { get; set; }
    public bool Per_EsEliminado { get; set; }
    public int Per_UsuarioRegistra { get; set; }
    public DateTime Per_FechaRegistra { get; set; }
    public int? Per_UsuarioModifica { get; set; }
    public DateTime? Per_FechaModifica { get; set; }
}
