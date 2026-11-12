using System;

namespace Gestion.Colegial.Entities.Entities
{
    public partial class CumplimientoDocumentosResult
    {
        public int Emp_Id { get; set; }
        public string Emp_Codigo { get; set; }
        public string NombreCompleto { get; set; }
        public string Per_Identidad { get; set; }
        public string Documento { get; set; }
        public bool EsObligatorio { get; set; }
        public int? DocEmp_Id { get; set; }
        public bool? EsEntregado { get; set; }
        public DateTime? FechaEntrega { get; set; }
        public DateTime? Doc_FechaVencimiento { get; set; }
        public string EstadoVencimiento { get; set; }
        public string Observacion { get; set; }
    }
}
