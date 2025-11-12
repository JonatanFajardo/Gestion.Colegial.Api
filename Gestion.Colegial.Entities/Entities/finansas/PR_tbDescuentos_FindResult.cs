
#nullable enable
using System;
using System.ComponentModel.DataAnnotations;

namespace Gestion.Colegial.Entities.Entities;

public class PR_tbDescuentos_FindResult
{
    public int Des_Id { get; set; }
    public string Des_Descripcion { get; set; } = string.Empty;
    public string Des_TipoDescuento { get; set; } = "P";
    public decimal Des_Valor { get; set; }
    public bool Des_EsActivo { get; set; }
    public bool Per_EsEliminado { get; set; }
    public int Per_UsuarioRegistra { get; set; }
    public DateTime Per_FechaRegistra { get; set; }
    public int? Per_UsuarioModifica { get; set; }
    public DateTime? Per_FechaModifica { get; set; }
}
