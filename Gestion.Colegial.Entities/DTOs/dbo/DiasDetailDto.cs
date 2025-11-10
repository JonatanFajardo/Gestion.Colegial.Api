namespace Gestion.Colegial.Entities.DTOs
{
    public partial class DiaDetailDto    {
        public int? DiaId { get; set; }
        public string DescripcionDia { get; set; }
        public string NombreUsuarioRegistraDia { get; set; }
        public DateTime? FechaRegistroDia { get; set; }
        public string NombreUsuarioModificaDia { get; set; }
        public DateTime? FechaModificacionDia { get; set; }
    }
}