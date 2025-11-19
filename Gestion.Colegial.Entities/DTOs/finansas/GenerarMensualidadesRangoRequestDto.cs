namespace Gestion.Colegial.Entities.DTOs.finansas
{
    public class GenerarMensualidadesRangoRequestDto
    {
        public byte MesInicio { get; set; }
        public byte MesFin { get; set; }
        public short Anio { get; set; }
        public int UsuarioId { get; set; }
    }
}
