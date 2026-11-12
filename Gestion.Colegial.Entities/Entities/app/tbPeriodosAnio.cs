#nullable disable
using System;

namespace Gestion.Colegial.Entities.Entities
{
    /// <summary>
    /// Período de reporte/evaluación de un año lectivo (Fase 2, espejo de los
    /// "reporting periods" de Skuul). Cada año (tbAnioLectivo) se subdivide en
    /// parciales/semestres/trimestres/bimestres con fechas y su propio orden.
    /// </summary>
    public partial class tbPeriodosAnio
    {
        /// <summary>Identificador único del período.</summary>
        public int Pan_Id { get; set; }
        /// <summary>Año lectivo al que pertenece (FK a tbAnioLectivo.Ani_Id).</summary>
        public int Ani_Id { get; set; }
        /// <summary>Nombre visible (ej. "I Parcial", "Primer Semestre").</summary>
        public string Pan_Nombre { get; set; }
        /// <summary>Tipo: parcial / semestre / trimestre / bimestre / otro.</summary>
        public string Pan_Tipo { get; set; }
        /// <summary>Orden de aparición dentro del año.</summary>
        public short Pan_Orden { get; set; }
        /// <summary>Fecha de inicio del período.</summary>
        public DateTime? Pan_FechaInicio { get; set; }
        /// <summary>Fecha de fin del período.</summary>
        public DateTime? Pan_FechaFin { get; set; }
        /// <summary>Estado del ciclo de vida: 1 Borrador · 2 Programado · 3 Abierto · 4 Cerrando · 5 Cerrado · 6 Archivado.</summary>
        public byte Pan_Estado { get; set; }
        /// <summary>Indica si el período está activo (1) o inhabilitado (0).</summary>
        public bool Pan_EsActivo { get; set; }
        /// <summary>Indica si el período fue eliminado (baja lógica).</summary>
        public bool Pan_EsEliminado { get; set; }
        /// <summary>Usuario que registró.</summary>
        public int? Pan_UsuarioRegistra { get; set; }
        /// <summary>Fecha de registro.</summary>
        public DateTime Pan_FechaRegistra { get; set; }
        /// <summary>Usuario que modificó.</summary>
        public int? Pan_UsuarioModifica { get; set; }
        /// <summary>Fecha de modificación.</summary>
        public DateTime? Pan_FechaModifica { get; set; }
    }
}
