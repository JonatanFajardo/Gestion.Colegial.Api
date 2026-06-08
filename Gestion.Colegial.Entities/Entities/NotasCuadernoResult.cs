using System;

namespace Gestion.Colegial.Entities.Entities
{
    public class NotasCuadernoResult
    {
        public int Alu_Id { get; set; }
        public string Alu_NombreCompleto { get; set; }
        public int? Not_Id { get; set; }
        public decimal? Not_Nota { get; set; }
        public DateTime? Not_FechaRegistra { get; set; }
        public DateTime? Not_FechaModifica { get; set; }
    }

    public class NotasBoletinResult
    {
        public int Not_Id { get; set; }
        public int Mat_Id { get; set; }
        public string Mat_Nombre { get; set; }
        public int Pac_Id { get; set; }
        public string Pac_Descripcion { get; set; }
        public decimal Not_Nota { get; set; }
        public int Sem_Id { get; set; }
        public string Sem_Descripcion { get; set; }
        public DateTime Not_Año { get; set; }
    }
}
