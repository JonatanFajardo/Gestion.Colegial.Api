namespace Gestion.Colegial.Entities.DTOs
{
    /// <summary>
    /// Una acción sobre un período de notas (año, semestre, parcial): cerrar, publicar, despublicar,
    /// reabrir o fijar fechas. Quién escribe (Usuario) y si tiene "Cerrar y publicar parciales"
    /// (PuedeCerrar) los calcula el ADM con la sesión; el procedimiento los vuelve a validar.
    /// </summary>
    public class CierreParcialAccionDTO
    {
        public int Anio { get; set; }
        public int Sem_Id { get; set; }
        public int Pac_Id { get; set; }
        public string? Motivo { get; set; }
        /// <summary>Al cerrar con notas faltantes: confirmación explícita (con motivo).</summary>
        public bool ConfirmarFaltantes { get; set; }
        public DateTime? FechaInicio { get; set; }
        public DateTime? FechaLimite { get; set; }
        public int? Usuario { get; set; }
        public bool PuedeCerrar { get; set; }
    }
}
