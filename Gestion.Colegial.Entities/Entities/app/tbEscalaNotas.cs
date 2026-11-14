#nullable disable
using System;

namespace Gestion.Colegial.Entities.Entities
{
    /// <summary>
    /// Fila de la escala de notas: traduce un rango de promedio (0-100) a un concepto para el boletín.
    /// </summary>
    public partial class tbEscalaNotas
    {
        public int Esc_Id { get; set; }
        public string Esc_Concepto { get; set; }
        public string Esc_Abreviatura { get; set; }
        public decimal Esc_NotaDesde { get; set; }
        public decimal Esc_NotaHasta { get; set; }
        public bool Esc_Aprueba { get; set; }
        public int Esc_Orden { get; set; }
        public bool Esc_EsEliminado { get; set; }
        public int Esc_UsuarioRegistra { get; set; }
        public DateTime Esc_FechaRegistra { get; set; }
        public int? Esc_UsuarioModifica { get; set; }
        public DateTime? Esc_FechaModifica { get; set; }
    }
}
