
#nullable enable
using System;
using System.ComponentModel.DataAnnotations;

namespace Gestion.Colegial.Entities.Entities;

public class PR_tbMoratorias_FindResult
{
public int Mor_Id { get; set; }
public int Cco_Id { get; set; }
public int Mor_DiasAtraso { get; set; }
public decimal Mor_Porcentaje { get; set; }
public decimal Mor_MontoMora { get; set; }
public DateTime Mor_FechaCalculo { get; set; }
public bool Per_EsEliminado { get; set; }
public int Per_UsuarioRegistra { get; set; }
public DateTime Per_FechaRegistra { get; set; }
public int? Per_UsuarioModifica { get; set; }
public DateTime? Per_FechaModifica { get; set; }
}
