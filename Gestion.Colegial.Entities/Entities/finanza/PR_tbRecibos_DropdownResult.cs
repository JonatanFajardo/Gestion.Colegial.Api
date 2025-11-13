
#nullable enable
using System;
using System.ComponentModel.DataAnnotations;

namespace Gestion.Colegial.Entities.Entities;

public class PR_tbRecibos_DropdownResult
{
    public int Rec_Id { get; set; }
    public string Texto { get; set; } = string.Empty;
}
