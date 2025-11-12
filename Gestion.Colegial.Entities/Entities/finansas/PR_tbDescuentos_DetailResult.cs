
#nullable enable
using System;
using System.ComponentModel.DataAnnotations;

namespace Gestion.Colegial.Entities.Entities;

public class PR_tbDescuentos_DetailResult
{
    public int Des_Id { get; set; }
    public string Des_Descripcion { get; set; } = string.Empty;
    public string Des_TipoDescuento { get; set; } = string.Empty;
    public decimal Des_Valor { get; set; }
    public bool Des_EsActivo { get; set; }
    public int VecesAplicado { get; set; }
}
