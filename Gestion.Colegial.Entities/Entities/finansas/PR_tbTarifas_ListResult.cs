
#nullable enable
using System;
using System.ComponentModel.DataAnnotations;

namespace Gestion.Colegial.Entities.Entities;

public class PR_tbTarifas_ListResult
{
    public int Tar_Id { get; set; }
    public int Cpa_Id { get; set; }
    public decimal Tar_Monto { get; set; }
    public short Tar_AnioVigencia { get; set; }
}
