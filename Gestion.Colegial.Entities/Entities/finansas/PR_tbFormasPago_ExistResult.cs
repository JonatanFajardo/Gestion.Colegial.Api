
#nullable enable
using System;
using System.ComponentModel.DataAnnotations;

namespace Gestion.Colegial.Entities.Entities;

public class PR_tbFormasPago_ExistResult
{
    public bool Exists { get; set; }
    public string? Message { get; set; }
}
