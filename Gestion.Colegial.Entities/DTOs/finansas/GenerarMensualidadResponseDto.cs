namespace Gestion.Colegial.Entities.DTOs.finansas
{
    public class GenerarMensualidadResponseDto
    {
        public int TotalGenerados { get; set; }
        public decimal MontoTotal { get; set; }
        public byte Mes { get; set; }
        public string NombreMes { get; set; }
        public short Anio { get; set; }
        public string Mensaje { get; set; }
    }
}
