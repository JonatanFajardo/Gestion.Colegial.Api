
#nullable enable
using System;
using System.ComponentModel.DataAnnotations;

namespace Gestion.Colegial.Entities.Entities;

public class PR_tbFormasPago_DetailResult
{
    public int Fpa_Id { get; set; }
    public string Fpa_Descripcion { get; set; } = string.Empty;
    public bool Fpa_EsActivo { get; set; }
    public int CantidadPagos { get; set; }
}
