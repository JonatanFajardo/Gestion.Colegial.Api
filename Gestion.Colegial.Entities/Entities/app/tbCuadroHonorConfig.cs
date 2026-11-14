#nullable disable
using System;

namespace Gestion.Colegial.Entities.Entities
{
    /// <summary>
    /// Umbrales de promedio para el cuadro de honor (una sola fila, Chc_Id = 1).
    /// </summary>
    public partial class tbCuadroHonorConfig
    {
        public int Chc_Id { get; set; }
        public decimal Chc_UmbralHonor { get; set; }
        public decimal Chc_UmbralHonorSuperior { get; set; }
        public int? Chc_UsuarioModifica { get; set; }
        public DateTime? Chc_FechaModifica { get; set; }
    }
}
