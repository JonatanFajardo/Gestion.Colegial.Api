#nullable disable

namespace Gestion.Colegial.Entities.DTOs
{
    public partial class tbDepartamentoEmpleadosDto
    {
        public int DepartamentoId { get; set; }
        public string DescripcionDepartamento { get; set; }
        public bool EsEliminado { get; set; }
        public int UsuarioRegistra { get; set; }
        public DateTime FechaRegistra { get; set; }
        public int? UsuarioModifica { get; set; }
        public DateTime? FechaModifica { get; set; }
    }
}
