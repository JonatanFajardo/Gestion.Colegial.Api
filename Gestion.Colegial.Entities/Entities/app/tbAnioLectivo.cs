#nullable disable
using System;

namespace Gestion.Colegial.Entities.Entities
{
    /// <summary>
    /// Año lectivo como entidad (capa multi-año). Reemplaza el valor suelto
    /// que vivía en app.tbConfiguracion ('anio_lectivo_actual').
    /// </summary>
    public partial class tbAnioLectivo
    {
        /// <summary>Identificador único del año lectivo.</summary>
        public int Ani_Id { get; set; }
        /// <summary>Año base (ej. 2026).</summary>
        public int Ani_Anio { get; set; }
        /// <summary>Nombre visible (ej. "2026" o "2026-2027").</summary>
        public string Ani_Nombre { get; set; }
        /// <summary>Fecha de inicio del ciclo.</summary>
        public DateTime? Ani_FechaInicio { get; set; }
        /// <summary>Fecha de fin del ciclo.</summary>
        public DateTime? Ani_FechaFin { get; set; }
        /// <summary>Estado del ciclo de vida: 1 Borrador · 2 Programado · 3 Abierto · 4 Cerrando · 5 Cerrado · 6 Archivado.</summary>
        public byte Ani_Estado { get; set; }
        /// <summary>Indica si el año está activo (1) o inhabilitado (0).</summary>
        public bool Ani_EsActivo { get; set; }
        /// <summary>Indica si el año fue eliminado (baja lógica).</summary>
        public bool Ani_EsEliminado { get; set; }
        /// <summary>Usuario que registró.</summary>
        public int? Ani_UsuarioRegistra { get; set; }
        /// <summary>Fecha de registro.</summary>
        public DateTime Ani_FechaRegistra { get; set; }
        /// <summary>Usuario que modificó.</summary>
        public int? Ani_UsuarioModifica { get; set; }
        /// <summary>Fecha de modificación.</summary>
        public DateTime? Ani_FechaModifica { get; set; }
    }
}
