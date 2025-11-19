namespace Gestion.Colegial.Entities.DTOs.finansas
{
    public class GenerarMensualidadRequestDto
    {
        public byte Mes { get; set; }
        public short Anio { get; set; }
        public int UsuarioId { get; set; }
        public int? ConceptoMensualidadId { get; set; }
    }
}
