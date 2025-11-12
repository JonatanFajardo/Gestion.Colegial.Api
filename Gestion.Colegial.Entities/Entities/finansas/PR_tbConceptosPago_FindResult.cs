
#nullable enable
using System;
using System.ComponentModel.DataAnnotations;

namespace Gestion.Colegial.Entities.Entities;

public class PR_tbConceptosPago_FindResult
{
    public int Cpa_Id { get; set; }
    public string Cpa_Descripcion { get; set; } = string.Empty;
    public bool Cpa_EsRecurrente { get; set; }
    public bool Cpa_EsObligatorio { get; set; }
    public bool Cpa_EsActivo { get; set; }
    public bool Per_EsEliminado { get; set; }
    public int Per_UsuarioRegistra { get; set; }
    public DateTime Per_FechaRegistra { get; set; }
    public int? Per_UsuarioModifica { get; set; }
    public DateTime? Per_FechaModifica { get; set; }
}
