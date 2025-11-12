
#nullable enable
using System;
using System.ComponentModel.DataAnnotations;

namespace ModuloFinanciero.Results;

public class PR_tbTarifas_ExistResult
{
    public bool Exists { get; set; }
    public string? Message { get; set; }
}
