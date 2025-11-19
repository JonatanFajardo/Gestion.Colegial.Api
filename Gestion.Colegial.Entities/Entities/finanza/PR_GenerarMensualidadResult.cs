namespace Gestion.Colegial.Entities.Entities
{
    public class PR_GenerarMensualidadResult
    {
        public int TotalGenerados { get; set; }
        public decimal MontoTotal { get; set; }
        public byte Mes { get; set; }
        public string NombreMes { get; set; }
        public short Anio { get; set; }
        public string Mensaje { get; set; }
    }
}
