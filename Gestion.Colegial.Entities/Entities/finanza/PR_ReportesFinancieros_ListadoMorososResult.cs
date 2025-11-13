
#nullable enable
using System;
using System.ComponentModel.DataAnnotations;

namespace Gestion.Colegial.Entities.Entities;

public class PR_ReportesFinancieros_ListadoMorososResult
{
    public int Alu_Id { get; set; }
    public string AlumnoNombre { get; set; } = string.Empty;
    public string? AlumnoIdentidad { get; set; }
    public int CantidadCuentasVencidas { get; set; }
    public decimal TotalDeuda { get; set; }
    public decimal TotalMora { get; set; }
    public int DiasMaximoVencimiento { get; set; }
    public DateTime? FechaUltimoPago { get; set; }
}
