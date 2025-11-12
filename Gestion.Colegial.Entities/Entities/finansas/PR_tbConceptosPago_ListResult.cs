
#nullable enable
using System;
using System.ComponentModel.DataAnnotations;

namespace Gestion.Colegial.Entities.Entities;

public class PR_tbConceptosPago_ListResult
{
    public int Cpa_Id { get; set; }
    public string Cpa_Descripcion { get; set; } = string.Empty;
    public bool Cpa_EsRecurrente { get; set; }
    public bool Cpa_EsObligatorio { get; set; }
    public bool Cpa_EsActivo { get; set; }
}
