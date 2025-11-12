
#nullable enable
using System;
using System.ComponentModel.DataAnnotations;

namespace Gestion.Colegial.Entities.Entities;

public class PR_tbTarifas_DetailResult
{
    public int Tar_Id { get; set; }
    public string Concepto { get; set; } = string.Empty;
    public decimal Tar_Monto { get; set; }
    public short Tar_AnioVigencia { get; set; }
    public int? Niv_Id { get; set; }
    public int? Cun_Id { get; set; }
}
