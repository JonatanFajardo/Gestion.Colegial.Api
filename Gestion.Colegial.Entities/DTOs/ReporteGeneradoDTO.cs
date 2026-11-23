namespace Gestion.Colegial.Entities.DTOs
{
    /// <summary>Un reporte que generó una persona en el Centro de reportes (lo manda el ADM).</summary>
    public class ReporteGeneradoDTO
    {
        public int Usu_Id { get; set; }
        public string? Rge_Clave { get; set; }
        public string? Rge_Titulo { get; set; }
        public string? Rge_Parametros { get; set; }
        public string? Rge_Resumen { get; set; }
        /// <summary>listo | fallo</summary>
        public string? Rge_Estado { get; set; }
        public int? Rge_Filas { get; set; }
        public string? Rge_Error { get; set; }
        public DateTime? Rge_Fecha { get; set; }
    }
}
