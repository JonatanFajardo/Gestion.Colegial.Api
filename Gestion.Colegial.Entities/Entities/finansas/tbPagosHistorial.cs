
#nullable enable
using System;
using System.ComponentModel.DataAnnotations;

namespace Gestion.Colegial.Entities.Entities;

public class tbPagosHistorial
{
    [Key]
    public int Pgh_Id { get; set; }
    public int Pag_Id { get; set; }
    public string Pgh_Accion { get; set; } = string.Empty;
    public string? Pgh_Detalle { get; set; }
    public DateTime Pgh_Fecha { get; set; }
    public int Pgh_Usuario { get; set; }
}
