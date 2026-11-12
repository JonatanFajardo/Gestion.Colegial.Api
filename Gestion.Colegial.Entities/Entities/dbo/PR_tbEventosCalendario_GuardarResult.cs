namespace Gestion.Colegial.Entities.Entities
{
    /// <summary>Resultado de guardar un día del calendario. Creado = false si era un feriado ya cargado.</summary>
    public class PR_tbEventosCalendario_GuardarResult
    {
        public int Eve_Id { get; set; }
        public bool Creado { get; set; }
    }
}
