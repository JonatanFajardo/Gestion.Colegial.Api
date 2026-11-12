using System;

namespace Gestion.Colegial.Entities.Entities
{
    public class PR_tbTareas_ListResult
    {
        public int      Tar_Id           { get; set; }
        public int      Hor_Id           { get; set; }
        public string   Tar_Titulo       { get; set; }
        public string   Tar_Descripcion  { get; set; }
        public DateTime Tar_FechaEntrega { get; set; }
        public decimal  Tar_Punteo       { get; set; }
        public string   Tar_Estado       { get; set; }
        public DateTime Tar_FechaRegistra { get; set; }
        public string   Mat_Nombre       { get; set; }
        public string   Sec_Descripcion  { get; set; }
    }
}
