namespace Gestion.Colegial.Entities.Entities
{
    /// <summary>
    /// Resultado del SP app.PR_tbAnioLectivo_RollForward: conteos de filas
    /// copiadas del año origen al año destino (estructura en borrador).
    /// </summary>
    public class PR_RollForwardResult
    {
        /// <summary>Períodos copiados a tbPeriodosAnio.</summary>
        public int periodos_copiados { get; set; }
        /// <summary>Secciones copiadas a tbSeccionesAnio.</summary>
        public int secciones_copiadas { get; set; }
        /// <summary>Ofertas (asignaturas por grado) copiadas a tbOfertasAnio.</summary>
        public int ofertas_copiadas { get; set; }
    }
}
