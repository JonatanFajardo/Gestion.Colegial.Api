namespace Gestion.Colegial.Entities.Entities
{
    /// <summary>Un día del calendario escolar (vista de mes, detalle y calendario del alumno). Audiencia vacía = todo el colegio.</summary>
    public class PR_tbEventosCalendario_ListResult
    {
        public int Eve_Id { get; set; }
        public int? Ani_Id { get; set; }
        public string Eve_Titulo { get; set; }
        public string Eve_Descripcion { get; set; }
        public string Eve_Tipo { get; set; }
        public string Eve_Lugar { get; set; }
        public bool Eve_TodoElDia { get; set; }
        public DateTime Eve_Inicio { get; set; }
        public DateTime Eve_Fin { get; set; }
        public bool Eve_EsPublicado { get; set; }
        public string Eve_ClaveOrigen { get; set; }
        public bool Eve_CierraColegio { get; set; }
        public string Audiencia { get; set; }
        public int AudienciaCantidad { get; set; }
    }
}
