
#nullable enable
using System;
using System.ComponentModel.DataAnnotations;

namespace Gestion.Colegial.Entities.Entities;

public class PR_tbEstadosPago_FindResult
{
    public int Epa_Id { get; set; }
    public string Epa_Descripcion { get; set; } = string.Empty;
    public bool Per_EsEliminado { get; set; }
    public int Per_UsuarioRegistra { get; set; }
    public DateTime Per_FechaRegistra { get; set; }
    public int? Per_UsuarioModifica { get; set; }
    public DateTime? Per_FechaModifica { get; set; }
}
