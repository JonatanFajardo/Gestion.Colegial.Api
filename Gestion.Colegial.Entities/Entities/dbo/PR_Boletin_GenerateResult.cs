using System;

namespace Gestion.Colegial.Entities.Entities
{
    public class PR_Boletin_GenerateResult
    {
        public int Alu_Id { get; set; }
        public string Alu_NombreCompleto { get; set; }
        public string Cur_Nombre { get; set; }
        public string Sec_Nombre { get; set; }
        public int Mat_Id { get; set; }
        public string Mat_Nombre { get; set; }
        public int Par_Id { get; set; }
        public string Par_Descripcion { get; set; }
        public decimal? Not_Nota { get; set; }
        public int Anio { get; set; }
        public int? Sem_Id { get; set; }
        public string Sem_Descripcion { get; set; }
        public string Par_Nombre { get; set; }
    }
}
