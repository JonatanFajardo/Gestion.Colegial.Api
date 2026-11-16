using System;
using System.Collections.Generic;

namespace Gestion.Colegial.Entities.DTOs.finansas
{
    public class PagoFindDto
    {
        public int PagoId { get; set; }
        public int AlumnoId { get; set; }
        public int? EncargadoId { get; set; }
        public int FormaPagoId { get; set; }
        public decimal MontoTotal { get; set; }
        public DateTime FechaPago { get; set; }
        public string NumeroReferencia { get; set; } = string.Empty;
        public string Observaciones { get; set; } = string.Empty;
        public int UsuarioId { get; set; }
        public bool EsEliminado { get; set; }
        public int UsuarioRegistraId { get; set; }
        public DateTime FechaRegistro { get; set; }
        public int? UsuarioModificaId { get; set; }
        public DateTime? FechaModifica { get; set; }

        /// <summary>Cargos (tbCuentasCobrar) que cubre el pago. Opcional: sin cargos solo se registra el pago.
        /// Con cargos, el pago los cubre del más viejo al más nuevo y lo que sobra va a saldo a favor.</summary>
        public List<int>? CuentasCobrarIds { get; set; }
    }
}