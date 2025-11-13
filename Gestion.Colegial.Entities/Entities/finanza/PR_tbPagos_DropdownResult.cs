
#nullable enable
using System;
using System.ComponentModel.DataAnnotations;

namespace Gestion.Colegial.Entities.Entities;

public class PR_tbPagos_DropdownResult
{
    public int Pag_Id { get; set; }
    public string Texto { get; set; } = string.Empty;
}
