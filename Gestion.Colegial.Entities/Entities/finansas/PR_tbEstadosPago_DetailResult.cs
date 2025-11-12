
#nullable enable
using System;
using System.ComponentModel.DataAnnotations;

namespace Gestion.Colegial.Entities.Entities;

public class PR_tbEstadosPago_DetailResult
{
    public int Epa_Id { get; set; }
    public string Epa_Descripcion { get; set; } = string.Empty;
    public int CantidadCuentas { get; set; }
}
