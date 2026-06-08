using System;

namespace Gestion.Colegial.Entities.Entities
{
    public partial class PR_tbDocumentosAlumno_ListResult
    {
        public int? Doa_Id { get; set; }
        public bool? Doa_EsEntregado { get; set; }
        public DateTime? Doa_FechaEntrega { get; set; }
        public string Doa_Observacion { get; set; }
        public int TDoc_Id { get; set; }
        public string TDoc_Descripcion { get; set; }
        public bool TDoc_EsObligatorio { get; set; }
    }
}
