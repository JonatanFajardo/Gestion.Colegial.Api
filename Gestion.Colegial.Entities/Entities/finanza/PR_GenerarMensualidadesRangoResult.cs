namespace Gestion.Colegial.Entities.Entities
{
    public class PR_GenerarMensualidadesRangoResult
    {
        public int TotalCuentasGeneradas { get; set; }
        public decimal MontoTotalGenerado { get; set; }
        public byte MesInicio { get; set; }
        public byte MesFin { get; set; }
        public short Anio { get; set; }
        public string Mensaje { get; set; }
    }
}
