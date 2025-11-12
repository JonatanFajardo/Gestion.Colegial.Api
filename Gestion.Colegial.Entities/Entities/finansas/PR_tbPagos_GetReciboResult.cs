
#nullable enable
using System;
using System.ComponentModel.DataAnnotations;

namespace Gestion.Colegial.Entities.Entities;

public class PR_tbPagos_GetReciboResult
{
    public int Rec_Id { get; set; }
    public int Pag_Id { get; set; }
    public string Rec_NumeroRecibo { get; set; } = string.Empty;
    public DateTime Rec_FechaEmision { get; set; }
    public string? Rec_RutaArchivo { get; set; }

    // Información del pago
    public decimal Pag_MontoTotal { get; set; }
    public DateTime Pag_FechaPago { get; set; }

    // Información del alumno
    public string AlumnoNombre { get; set; } = string.Empty;
    public string? AlumnoIdentidad { get; set; }

    // Información de forma de pago
    public string FormaPago { get; set; } = string.Empty;
}
