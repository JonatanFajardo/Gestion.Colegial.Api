namespace Gestion.Colegial.Entities.Entities
{
    /// <summary>Un destinatario de un día del calendario: sección del año, rol, empleado o alumno.</summary>
    public class PR_tbEventosCalendarioAudiencia_ListResult
    {
        public int Eva_Id { get; set; }
        public int Eve_Id { get; set; }
        public string Eva_Tipo { get; set; }
        public int Eva_RefId { get; set; }
        public string Eva_Nombre { get; set; }
        public string Eva_Detalle { get; set; }
        public int Eva_Orden { get; set; }
    }
}
