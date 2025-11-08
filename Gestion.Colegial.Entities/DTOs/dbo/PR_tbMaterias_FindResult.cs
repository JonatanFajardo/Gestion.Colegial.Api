namespace Gestion.Colegial.Entities.DTOs
{
    public partial class MateriaFindDto
    {
        public int MateriaId { get; set; }
        public string NombreMateria { get; set; }
        public string DescripcionDuracion { get; set; }
        public bool EsActivoMateria { get; set; }
    }
}