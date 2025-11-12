
#nullable enable
using System;
using System.ComponentModel.DataAnnotations;

namespace Gestion.Colegial.Entities.Entities;

public class PR_tbTarifas_DropdownResult
{
    public int Tar_Id { get; set; }
    public string Texto { get; set; } = string.Empty;
}
