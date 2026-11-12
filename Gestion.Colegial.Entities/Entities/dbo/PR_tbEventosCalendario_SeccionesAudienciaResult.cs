namespace Gestion.Colegial.Entities.Entities
{
    /// <summary>Sección del año que se puede elegir en Para quién.</summary>
    public class PR_tbEventosCalendario_SeccionesAudienciaResult
    {
        public int Sea_Id { get; set; }
        public string Sea_Nombre { get; set; }
        public int Ani_Id { get; set; }
        public int Ani_Anio { get; set; }
        public int? Niv_Id { get; set; }
        public string Niv_Descripcion { get; set; }
        public int Sea_Estado { get; set; }
        public int Cun_Orden { get; set; }
    }
}
