using System;

namespace Gestion.Colegial.Entities.Entities
{
    public class PR_tbAnioLectivo_FindResult
    {
        public int Ani_Id { get; set; }
        public int Ani_Anio { get; set; }
        public string Ani_Nombre { get; set; }
        public DateTime? Ani_FechaInicio { get; set; }
        public DateTime? Ani_FechaFin { get; set; }
        public byte Ani_Estado { get; set; }
        public bool Ani_EsActivo { get; set; }
    }
}
