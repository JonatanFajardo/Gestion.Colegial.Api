using System;

namespace Gestion.Colegial.Entities.Entities
{
    public class PR_tbEntregasTarea_ListResult
    {
        public int      Alu_Id             { get; set; }
        public string   Alu_NombreCompleto { get; set; }
        public string   Per_Imagen         { get; set; }
        public int?     Ent_Id             { get; set; }
        public bool?    Ent_Entregado      { get; set; }
        public DateTime? Ent_FechaEntrega  { get; set; }
        public decimal? Ent_Nota           { get; set; }
        public string   Ent_Observacion    { get; set; }
        public int      TieneEntrega       { get; set; }
        public int      TieneNota          { get; set; }
    }
}
