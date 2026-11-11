#nullable disable
using System;

namespace Gestion.Colegial.Entities.Entities
{
    /// <summary>
    /// Sección viva de un año lectivo con su docente guía (homeroom).
    /// Espejo de "academic_cycle_sections" de Skuul (Fase 4 — Clases y profesores).
    /// Instancia, para un Ani_Id, la estructura de catálogo Nivel/Grado/Sección/Modalidad.
    /// </summary>
    public partial class tbSeccionesAnio
    {
        /// <summary>Identificador único de la sección del año.</summary>
        public int Sea_Id { get; set; }
        /// <summary>Año lectivo al que pertenece (FK app.tbAnioLectivo).</summary>
        public int Ani_Id { get; set; }
        /// <summary>Nivel educativo (FK).</summary>
        public int Niv_Id { get; set; }
        /// <summary>Grado académico / curso nivel (FK tbCursosNiveles).</summary>
        public int Cun_Id { get; set; }
        /// <summary>Sección A/B/C (FK tbSecciones).</summary>
        public int Sec_Id { get; set; }
        /// <summary>Modalidad (FK, opcional).</summary>
        public int? Mda_Id { get; set; }
        /// <summary>Profesor guía / homeroom (FK tbEmpleados, opcional).</summary>
        public int? Emp_Id { get; set; }
        /// <summary>Etiqueta visible, ej. "7mo A".</summary>
        public string Sea_Nombre { get; set; }
        /// <summary>Cupo máximo de alumnos.</summary>
        public int? Sea_Cupo { get; set; }
        /// <summary>Estado: 1 Borrador · 2 Planificada · 3 Activa · 4 Suspendida · 5 Cerrada · 6 Archivada.</summary>
        public byte Sea_Estado { get; set; }
        /// <summary>Baja lógica.</summary>
        public bool Sea_EsEliminado { get; set; }
        /// <summary>Usuario que registró.</summary>
        public int? Sea_UsuarioRegistra { get; set; }
        /// <summary>Fecha de registro.</summary>
        public DateTime Sea_FechaRegistra { get; set; }
        /// <summary>Usuario que modificó.</summary>
        public int? Sea_UsuarioModifica { get; set; }
        /// <summary>Fecha de modificación.</summary>
        public DateTime? Sea_FechaModifica { get; set; }
    }
}
