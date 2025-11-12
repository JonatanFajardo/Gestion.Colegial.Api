
#nullable enable
using System;
using System.ComponentModel.DataAnnotations;

namespace Gestion.Colegial.Entities.Entities;

public class tbCuentasCobrarHistorial
{
    [Key]
    public int Cgh_Id { get; set; }
    public int Cco_Id { get; set; }
    public string Cgh_Accion { get; set; } = string.Empty;
    public string? Cgh_Detalle { get; set; }
    public DateTime Cgh_Fecha { get; set; }
    public int Cgh_Usuario { get; set; }
}
