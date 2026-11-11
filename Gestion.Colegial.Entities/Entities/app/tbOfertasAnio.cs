#nullable disable
using System;

namespace Gestion.Colegial.Entities.Entities
{
    /// <summary>
    /// Oferta de asignatura por año lectivo (Fase 5). Espejo de course_offerings +
    /// teaching_assignments de Skuul: una materia que se dicta en el año, para un
    /// grado/sección, con un docente asignado.
    /// </summary>
    public partial class tbOfertasAnio
    {
        /// <summary>Identificador único de la oferta.</summary>
        public int Ofa_Id { get; set; }
        /// <summary>Año lectivo al que pertenece la oferta (FK app.tbAnioLectivo).</summary>
        public int Ani_Id { get; set; }
        /// <summary>Materia ofertada (FK app.tbMaterias).</summary>
        public int Mat_Id { get; set; }
        /// <summary>Grado académico (FK app.tbCursosNiveles). Opcional.</summary>
        public int? Cun_Id { get; set; }
        /// <summary>Sección-año (app.tbSeccionesAnio). Sin FK: tabla creada en paralelo. Opcional.</summary>
        public int? Sea_Id { get; set; }
        /// <summary>Docente asignado = empleado (FK app.tbEmpleados). Opcional.</summary>
        public int? Emp_Id { get; set; }
        /// <summary>Período (app.tbPeriodosAnio). Sin FK: tabla creada en paralelo. Opcional.</summary>
        public int? Pan_Id { get; set; }
        /// <summary>Horas semanales de la asignatura. Opcional.</summary>
        public int? Ofa_HorasSemana { get; set; }
        /// <summary>Estado: 1 Borrador · 2 Programada · 3 Activa · 4 Suspendida · 5 Cerrada · 6 Archivada.</summary>
        public byte Ofa_Estado { get; set; }
        /// <summary>Indica si la oferta fue eliminada (baja lógica).</summary>
        public bool Ofa_EsEliminado { get; set; }
        /// <summary>Usuario que registró.</summary>
        public int? Ofa_UsuarioRegistra { get; set; }
        /// <summary>Fecha de registro.</summary>
        public DateTime Ofa_FechaRegistra { get; set; }
        /// <summary>Usuario que modificó.</summary>
        public int? Ofa_UsuarioModifica { get; set; }
        /// <summary>Fecha de modificación.</summary>
        public DateTime? Ofa_FechaModifica { get; set; }
    }
}
