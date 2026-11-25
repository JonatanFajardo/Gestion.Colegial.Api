namespace Gestion.Colegial.Entities.DTOs
{
    /// <summary>
    /// Una acción del asistente de cierre del año (script 090): cambiar el estado del año, calcular,
    /// guardar una regla por nivel, registrar una recuperación, decidir, confirmar o deshacer una sección.
    /// Quién escribe (Usuario) y sus permisos (PuedeCerrar = "Cerrar el año", PuedeReabrir = "Reabrir el
    /// año escolar") los fija la API con el usuario firmado; el procedimiento los vuelve a validar.
    /// </summary>
    public class CierreAnioAccionDTO
    {
        public int Ani_Id { get; set; }
        public int? Sea_Id { get; set; }
        public int? Niv_Id { get; set; }
        public int? Rea_Id { get; set; }
        public int? Pra_Id { get; set; }
        /// <summary>iniciar | cancelar | cerrar | reabrir | archivar</summary>
        public string? Accion { get; set; }
        /// <summary>promovido | repite | gradua</summary>
        public string? Decision { get; set; }
        public string? Motivo { get; set; }
        public decimal? Nota { get; set; }
        public decimal? NotaMinima { get; set; }
        public int? MaxRecuperacion { get; set; }
        public bool Forzar { get; set; }
        public int? Usuario { get; set; }
        public bool PuedeCerrar { get; set; }
        public bool PuedeReabrir { get; set; }
    }
}
