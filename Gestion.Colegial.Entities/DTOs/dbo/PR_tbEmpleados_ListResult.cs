namespace Gestion.Colegial.Entities.DTOs
{
    public partial class EmpleadoListDto
    {
        public int EmpleadoId { get; set; }
        public string CodigoEmpleado { get; set; }
        public string NombreEmpleado { get; set; }
        public string EsActivo { get; set; }
        public string DescripcionTitulo { get; set; }
        public string DescripcionCargo { get; set; }
    }
}