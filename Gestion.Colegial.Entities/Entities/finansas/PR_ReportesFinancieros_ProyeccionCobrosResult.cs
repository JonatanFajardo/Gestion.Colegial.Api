
#nullable enable
using System;
using System.ComponentModel.DataAnnotations;

namespace Gestion.Colegial.Entities.Entities;

public class PR_ReportesFinancieros_ProyeccionCobrosResult
{
    public int Anio { get; set; }
    public int Mes { get; set; }
    public string MesNombre { get; set; } = string.Empty;
    public decimal TotalProyectado { get; set; }
    public decimal TotalCobrado { get; set; }
    public decimal TotalPendiente { get; set; }
    public decimal PorcentajeCobrado { get; set; }
}
