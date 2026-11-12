using System;

namespace Gestion.Colegial.Entities.Entities
{
    public class PR_tbTareas_FindResult
    {
        public int      Tar_Id           { get; set; }
        public int      Hor_Id           { get; set; }
        public string   Tar_Titulo       { get; set; }
        public string   Tar_Descripcion  { get; set; }
        public DateTime Tar_FechaEntrega { get; set; }
        public decimal  Tar_Punteo       { get; set; }
        public string   Tar_Estado       { get; set; }
    }
}
