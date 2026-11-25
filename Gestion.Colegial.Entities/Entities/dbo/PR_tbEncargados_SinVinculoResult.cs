namespace Gestion.Colegial.Entities.Entities
{
    /// <summary>
    /// Resultado de PR_tbEncargados_SinVinculo: alumnos activos sin encargado o encargados sin hijos.
    /// </summary>
    public partial class PR_tbEncargados_SinVinculoResult
    {
        public int Id { get; set; }
        public string Nombre { get; set; }
        public string Identidad { get; set; }
        public string Telefono { get; set; }
        public string Detalle { get; set; }
    }
}
