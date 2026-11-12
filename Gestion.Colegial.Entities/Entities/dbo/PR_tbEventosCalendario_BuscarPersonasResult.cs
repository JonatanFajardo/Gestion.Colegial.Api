namespace Gestion.Colegial.Entities.Entities
{
    /// <summary>Persona (empleado o alumno) encontrada para nombrarla en Para quién.</summary>
    public class PR_tbEventosCalendario_BuscarPersonasResult
    {
        public string Tipo { get; set; }
        public int Id { get; set; }
        public string Nombre { get; set; }
        public string Detalle { get; set; }
    }
}
