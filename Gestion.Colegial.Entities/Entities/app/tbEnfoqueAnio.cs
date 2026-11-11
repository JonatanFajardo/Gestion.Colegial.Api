#nullable disable
using System;

namespace Gestion.Colegial.Entities.Entities
{
    /// <summary>
    /// Enfoque de enseñanza por año lectivo (Fase 3, espejo del Instructional Model de Skuul).
    /// 1 registro por año lectivo (Ani_Id UNIQUE).
    /// </summary>
    public partial class tbEnfoqueAnio
    {
        /// <summary>Identificador único del enfoque.</summary>
        public int Enf_Id { get; set; }
        /// <summary>Año lectivo al que pertenece (FK a app.tbAnioLectivo.Ani_Id).</summary>
        public int Ani_Id { get; set; }
        /// <summary>Modelo de agrupación: grupo_fijo · hibrido · horario_materias.</summary>
        public string Enf_Modelo { get; set; }
        /// <summary>Razón/justificación opcional de la elección.</summary>
        public string Enf_Razon { get; set; }
        /// <summary>Indica si el enfoque fue eliminado (baja lógica).</summary>
        public bool Enf_EsEliminado { get; set; }
        /// <summary>Usuario que registró.</summary>
        public int? Enf_UsuarioRegistra { get; set; }
        /// <summary>Fecha de registro.</summary>
        public DateTime Enf_FechaRegistra { get; set; }
        /// <summary>Usuario que modificó.</summary>
        public int? Enf_UsuarioModifica { get; set; }
        /// <summary>Fecha de modificación.</summary>
        public DateTime? Enf_FechaModifica { get; set; }
    }
}
