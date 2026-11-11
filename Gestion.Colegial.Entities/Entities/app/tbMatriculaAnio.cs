#nullable disable
using System;

namespace Gestion.Colegial.Entities.Entities
{
    /// <summary>
    /// Matrícula del alumno por año lectivo (capa multi-año, expediente/transcript).
    /// Un alumno tiene a lo sumo una matrícula viva por año (UNIQUE Alu_Id + Ani_Id).
    /// </summary>
    public partial class tbMatriculaAnio
    {
        /// <summary>Identificador único de la matrícula-año.</summary>
        public int Mta_Id { get; set; }
        /// <summary>Alumno matriculado (FK app.tbAlumnos).</summary>
        public int Alu_Id { get; set; }
        /// <summary>Año lectivo (FK app.tbAnioLectivo).</summary>
        public int Ani_Id { get; set; }
        /// <summary>Sección-año donde cae el alumno (FK app.tbSeccionesAnio, opcional).</summary>
        public int? Sea_Id { get; set; }
        /// <summary>Estado: 1 Activa · 2 Promovido · 3 Repite · 4 Retirado · 5 Graduado.</summary>
        public byte Mta_Estado { get; set; }
        /// <summary>Indica si la matrícula fue eliminada (baja lógica).</summary>
        public bool Mta_EsEliminado { get; set; }
        /// <summary>Usuario que registró.</summary>
        public int? Mta_UsuarioRegistra { get; set; }
        /// <summary>Fecha de registro.</summary>
        public DateTime Mta_FechaRegistra { get; set; }
        /// <summary>Usuario que modificó.</summary>
        public int? Mta_UsuarioModifica { get; set; }
        /// <summary>Fecha de modificación.</summary>
        public DateTime? Mta_FechaModifica { get; set; }
    }
}
