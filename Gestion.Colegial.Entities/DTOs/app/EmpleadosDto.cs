#nullable disable

namespace Gestion.Colegial.Entities.DTOs
{
    public partial class tbEmpleadosDto
    {
        public int EmpleadoId { get; set; }
        public string CodigoEmpleado { get; set; }
        public int PersonaId { get; set; }
        public int TituloId { get; set; }
        public int CargoId { get; set; }
        public int? DepartamentoId { get; set; }
    }
}
