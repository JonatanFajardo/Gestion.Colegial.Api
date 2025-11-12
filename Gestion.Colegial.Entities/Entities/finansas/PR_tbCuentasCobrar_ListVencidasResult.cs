
#nullable enable
using System;
using System.ComponentModel.DataAnnotations;

namespace Gestion.Colegial.Entities.Entities;

public class PR_tbCuentasCobrar_ListVencidasResult
{
    public int Cco_Id { get; set; }
    public int Alu_Id { get; set; }
    public string AlumnoNombre { get; set; } = string.Empty;
    public string Concepto { get; set; } = string.Empty;
    public decimal Cco_MontoTotal { get; set; }
    public decimal Cco_MontoPendiente { get; set; }
    public DateTime Cco_FechaVencimiento { get; set; }
    public string Estado { get; set; } = string.Empty;
    public int DiasVencidos { get; set; }
    public decimal? MontoMora { get; set; }
}
