
#nullable enable
using System;
using System.ComponentModel.DataAnnotations;

namespace Gestion.Colegial.Entities.Entities;

public class PR_tbDescuentosAplicados_DropdownResult
{
    public int Dap_Id { get; set; }
    public string Texto { get; set; } = string.Empty;
}
