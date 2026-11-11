using System;

namespace Gestion.Colegial.Entities.Entities
{
    public class PR_tbMatriculas_ListResult
    {
        public int Matri_Id { get; set; }
        public int Alu_Id { get; set; }
        public string Alu_Nombre { get; set; }
        public int Matri_Anio { get; set; }
        public int? Cun_Id { get; set; }
        public string Cun_Descripcion { get; set; }
        public int? Sec_Id { get; set; }
        public string Sec_Descripcion { get; set; }
        public int? Est_Id { get; set; }
        public string Est_Descripcion { get; set; }
        public DateTime Matri_FechaInicio { get; set; }
        public DateTime? Matri_FechaFin { get; set; }
    }
}
