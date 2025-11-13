
#nullable enable
using System;
using System.ComponentModel.DataAnnotations;

namespace Gestion.Colegial.Entities.Entities;

public class PR_tbCuentasCobrar_PrevisualizarCargosResult
{
    public int Alu_Id { get; set; }
    public string NombreCompleto { get; set; } = string.Empty;
    public string Nivel { get; set; } = string.Empty;
    public string Curso { get; set; } = string.Empty;
    public string Seccion { get; set; } = string.Empty;
    public int CantidadConceptos { get; set; }
    public decimal MontoEstimado { get; set; }
}
