
#nullable enable
using System;
using System.ComponentModel.DataAnnotations;

namespace Gestion.Colegial.Entities.Entities;

public class PR_tbDescuentos_DropdownResult
{
    public int Des_Id { get; set; }
    public string Des_Descripcion { get; set; } = string.Empty;
}
