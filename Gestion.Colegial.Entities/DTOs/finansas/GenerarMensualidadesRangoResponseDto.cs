using System.Collections.Generic;

namespace Gestion.Colegial.Entities.DTOs.finansas
{
    public class GenerarMensualidadesRangoResponseDto
    {
        public int TotalCuentasGeneradas { get; set; }
        public decimal MontoTotalGenerado { get; set; }
        public byte MesInicio { get; set; }
        public byte MesFin { get; set; }
        public short Anio { get; set; }
        public string Mensaje { get; set; }
        public List<DetalleMesMensualidad> DetallePorMes { get; set; }
    }

    public class DetalleMesMensualidad
    {
        public byte Mes { get; set; }
        public string NombreMes { get; set; }
        public int TotalGenerados { get; set; }
        public decimal MontoTotal { get; set; }
    }
}
