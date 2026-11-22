namespace Gestion.Colegial.Entities.DTOs
{
    /// <summary>
    /// Quién escribe: su usuario y sus permisos (los calcula el ADM con la sesión).
    /// PuedeGestionar = "Gestionar planes de apoyo"; VerConfidenciales = "Ver planes confidenciales".
    /// </summary>
    public abstract class PlanApoyoEscritorDTO
    {
        public int? Usuario { get; set; }
        public bool PuedeGestionar { get; set; }
        public bool VerConfidenciales { get; set; }
    }

    /// <summary>Datos de un plan. Categoría: refuerzo | orientacion | conducta | salud | adecuacion.</summary>
    public class PlanApoyoGuardarDTO : PlanApoyoEscritorDTO
    {
        public int Apo_Id { get; set; }
        public int Alu_Id { get; set; }
        public string? Apo_Categoria { get; set; }
        public string? Apo_Titulo { get; set; }
        public string? Apo_Resumen { get; set; }
        public DateTime? Apo_FechaInicio { get; set; }
        public DateTime? Apo_FechaRevision { get; set; }
        public int? Usu_IdResponsable { get; set; }
        public bool Apo_EsConfidencial { get; set; }
        /// <summary>Al crear: true = queda activo de una vez; false = borrador.</summary>
        public bool Activar { get; set; }
        /// <summary>Al editar: versión que leyó quien edita.</summary>
        public int? Apo_Version { get; set; }
    }

    /// <summary>Mover el plan. Estado: borrador | activo | en_pausa | completado | cancelado.</summary>
    public class PlanApoyoEstadoDTO : PlanApoyoEscritorDTO
    {
        public int Apo_Id { get; set; }
        public string? Estado { get; set; }
        public string? Motivo { get; set; }
    }

    public class PlanApoyoPasoDTO : PlanApoyoEscritorDTO
    {
        public int Apo_Id { get; set; }
        public string? Apa_Descripcion { get; set; }
        public DateTime? Apa_FechaLimite { get; set; }
        public int? Usu_IdResponsable { get; set; }
    }

    /// <summary>Marcar hecho o quitar un paso.</summary>
    public class PlanApoyoPasoAccionDTO : PlanApoyoEscritorDTO
    {
        public int Apo_Id { get; set; }
        public int Apa_Id { get; set; }
    }

    public class PlanApoyoNotaDTO : PlanApoyoEscritorDTO
    {
        public int Apo_Id { get; set; }
        public string? Apn_Texto { get; set; }
    }

    public class PlanApoyoEliminarDTO : PlanApoyoEscritorDTO
    {
        public int Apo_Id { get; set; }
    }
}
