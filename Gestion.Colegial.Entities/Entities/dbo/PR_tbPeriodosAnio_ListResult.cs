using System;

namespace Gestion.Colegial.Entities.Entities
{
    public class PR_tbPeriodosAnio_ListResult
    {
        public int Pan_Id { get; set; }
        public int Ani_Id { get; set; }
        public string Pan_Nombre { get; set; }
        public string Pan_Tipo { get; set; }
        public short Pan_Orden { get; set; }
        public DateTime? Pan_FechaInicio { get; set; }
        public DateTime? Pan_FechaFin { get; set; }
        public byte Pan_Estado { get; set; }
        public string Pan_EstadoDescripcion { get; set; }
        public bool Pan_EsActivo { get; set; }
    }
}
