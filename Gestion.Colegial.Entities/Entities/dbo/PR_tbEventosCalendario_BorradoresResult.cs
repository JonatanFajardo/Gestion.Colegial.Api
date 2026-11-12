namespace Gestion.Colegial.Entities.Entities
{
    /// <summary>Cuántos días del calendario siguen en borrador en un mes (una fila por mes con borradores).</summary>
    public class PR_tbEventosCalendario_BorradoresResult
    {
        /// <summary>Mes del inicio del día, 'yyyy-MM'.</summary>
        public string Mes { get; set; }
        public int Borradores { get; set; }
    }
}
