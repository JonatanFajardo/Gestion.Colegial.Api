namespace Gestion.Colegial.Entities.Entities
{
    /// <summary>Si el colegio cierra un día para una sección (feriado o cierre publicado).</summary>
    public class PR_tbEventosCalendario_CierreEnFechaResult
    {
        public bool Cerrado { get; set; }
        public int? Eve_Id { get; set; }
        public string Eve_Titulo { get; set; }
        public string Eve_Tipo { get; set; }
        public DateTime? Eve_Inicio { get; set; }
        public DateTime? Eve_Fin { get; set; }
        public int? Sea_Id { get; set; }
        public DateTime Fecha { get; set; }
    }
}
