namespace Gestion.Colegial.Entities.Entities
{
    /// <summary>Un día de hoy o de los próximos días (tarjeta de los dashboards).</summary>
    public class PR_tbEventosCalendario_ProximosResult
    {
        public bool EsHoy { get; set; }
        public int Eve_Id { get; set; }
        public string Eve_Titulo { get; set; }
        public string Eve_Tipo { get; set; }
        public string Eve_Lugar { get; set; }
        public bool Eve_TodoElDia { get; set; }
        public DateTime Eve_Inicio { get; set; }
        public DateTime Eve_Fin { get; set; }
        public bool Eve_CierraColegio { get; set; }
    }
}
