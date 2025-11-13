
#nullable enable
using System;
using System.ComponentModel.DataAnnotations;

namespace Gestion.Colegial.Entities.Entities;

public class PR_ReportesFinancieros_IngresosPorMesResult
{
    public int Anio { get; set; }
    public int Mes { get; set; }
    public string MesNombre { get; set; } = string.Empty;
    public decimal TotalIngresos { get; set; }
    public int CantidadPagos { get; set; }
    public decimal PromedioIngresos { get; set; }
}
