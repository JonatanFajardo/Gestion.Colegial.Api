using System;

namespace Gestion.Colegial.Entities.Entities
{
    public class PR_tbPlanClases_ListResult
    {
        public int    Pla_Id           { get; set; }
        public int    Hor_Id           { get; set; }
        public short  Pla_Semana       { get; set; }
        public string Pla_Tema         { get; set; }
        public string Pla_Objetivos    { get; set; }
        public string Pla_Recursos     { get; set; }
        public string Pla_Estado       { get; set; }
        public DateTime Pla_FechaRegistra { get; set; }
        public string Mat_Nombre       { get; set; }
        public string Sec_Descripcion  { get; set; }
    }
}
