
#nullable enable
using System;
using System.ComponentModel.DataAnnotations;

namespace Gestion.Colegial.Entities.Entities;

public class PR_tbConceptosPago_DropdownResult
{
    public int Cpa_Id { get; set; }
    public string Cpa_Descripcion { get; set; } = string.Empty;
}
